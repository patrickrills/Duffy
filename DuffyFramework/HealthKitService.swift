//
//  HealthKitService.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import HealthKit

public class HealthKitService
{
    private static let instance: HealthKitService = HealthKitService()
    private var healthStore: HKHealthStore?
    public var observerQueries: [String : HKObserverQuery]?

    init()
    {
        if (HKHealthStore.isHealthDataAvailable())
        {
            healthStore = HKHealthStore()
            observerQueries = [String : HKObserverQuery]()
        }
    }

    public class func getInstance() -> HealthKitService
    {
        return instance
    }

    public func getSteps(forDate: NSDate, onRetrieve: ((Int, NSDate) -> Void)?, onFailure:  ((NSError?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else { return }

        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Era, .Year, .Month, .Day], fromDate: forDate)
        components.calendar = calendar
        let startDate = calendar.dateFromComponents(components)

        guard startDate != nil else { return }

        let forSpecificDay = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate!, options: NSCalendarOptions(rawValue: 0)), options: .StrictStartDate)
        let interval = NSDateComponents()
        interval.day = 1

        if let store = healthStore, stepType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        {
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                    quantitySamplePredicate: forSpecificDay,
                    options: .CumulativeSum,
                    anchorDate: startDate!,
                    intervalComponents: interval)

            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: NSError?) in

                if let r = results where error == nil
                {
                    var steps: Int = 0
                    var sampleDate = NSDate()

                    r.enumerateStatisticsFromDate(query.anchorDate, toDate: query.anchorDate) {
                        statistics, stop in

                        if let quantity = statistics.sumQuantity() {
                            sampleDate = statistics.startDate
                            steps += Int(quantity.doubleValueForUnit(HKUnit.countUnit()))
                        }
                    }

                    if let successBlock = onRetrieve
                    {
                        successBlock(steps, sampleDate)
                    }
                }
                else
                {
                    if let failBlock = onFailure
                    {
                        failBlock(error)
                    }
                }
            }

            store.executeQuery(query)
        }
    }

    public func authorizeForSteps(onAuthorized: (() -> (Void))?, onFailure: (() -> (Void))?)
    {
        if let store = healthStore, stepType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount) where HKHealthStore.isHealthDataAvailable()
        {
            store.requestAuthorizationToShareTypes(nil, readTypes: [stepType], completion: {
                (success: Bool, error: NSError?) in
                if let successBlock = onAuthorized where success
                {
                    successBlock()
                }
                else
                {
                    if let failBlock = onFailure
                    {
                        failBlock()
                    }
                }
            })
        }
        else
        {
            if let failBlock = onFailure
            {
                failBlock()
            }
        }
    }
    
    public func initializeBackgroundQueries()
    {
        if let store = healthStore where observerQueries != nil
        {
            let stepsIdenitifier = HKQuantityTypeIdentifierStepCount
            let stepsType = HKQuantityType.quantityTypeForIdentifier(stepsIdenitifier)
            
            if let sampleType = stepsType
            {
                if let stepsQuery = observerQueries![stepsIdenitifier]
                {
                    store.stopQuery(stepsQuery)
                    observerQueries!.removeValueForKey(stepsIdenitifier)
                }
                
                let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: {
                    [weak self] (updateQuery: HKObserverQuery, handler: HKObserverQueryCompletionHandler, updateError: NSError?) in
                    
                    NSLog("Observer query fired")
                    
                    self?.getSteps(NSDate(),
                        onRetrieve: {
                            (steps: Int, forDay: NSDate) in
                            
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                            {
                                NSLog(String(format: "Update complication with %d steps", steps))
                                WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache()])
                            }
                            
                        },
                        onFailure: nil)
                    
                    
                    handler()
                    
                })
                
                NSLog("Observer query fired")
                
                observerQueries![stepsIdenitifier] = query
                store.executeQuery(query)
                
                #if os(iOS)
                    store.enableBackgroundDeliveryForType(sampleType, frequency: .Hourly, withCompletion: {
                        (success: Bool, error: NSError?) in
                        if (success)
                        {
                            NSLog("Background updates enabled for steps")
                        }
                    })
                #endif
            }
        }
    }
}