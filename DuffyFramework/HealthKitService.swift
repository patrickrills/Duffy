//
//  HealthKitService.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import HealthKit
import os.log

open class HealthKitService
{
    fileprivate static let instance: HealthKitService = HealthKitService()
    fileprivate var healthStore: HKHealthStore?
    fileprivate var eventDelegate: HealthEventDelegate?
    open var observerQueries: [String : HKObserverQuery]?

    init()
    {
        if (HKHealthStore.isHealthDataAvailable())
        {
            healthStore = HKHealthStore()
            observerQueries = [String : HKObserverQuery]()
        }
    }

    open class func getInstance() -> HealthKitService
    {
        return instance
    }
    
    open func setEventDelegate(_ delegate: HealthEventDelegate)
    {
        eventDelegate = delegate
    }

    open func getSteps(_ forDate: Date, onRetrieve: ((Int, Date) -> Void)?, onFailure:  ((Error?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else { return }

        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.era, .year, .month, .day], from: forDate)
        (components as NSDateComponents).calendar = calendar
        let startDate = calendar.date(from: components)

        guard startDate != nil else { return }

        let forSpecificDay = HKQuery.predicateForSamples(withStart: startDate!, end: (calendar as NSCalendar).date(byAdding: .day, value: 1, to: startDate!, options: NSCalendar.Options(rawValue: 0)), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1

        if let store = healthStore, let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        {
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                    quantitySamplePredicate: forSpecificDay,
                    options: .cumulativeSum,
                    anchorDate: startDate!,
                    intervalComponents: interval)

            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in

                if let r = results , error == nil
                {
                    var steps: Int = 0
                    var sampleDate = Date()

                    r.enumerateStatistics(from: query.anchorDate, to: query.anchorDate) {
                        statistics, stop in

                        if let quantity = statistics.sumQuantity() {
                            sampleDate = statistics.startDate
                            steps += Int(quantity.doubleValue(for: HKUnit.count()))
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

            store.execute(query)
        }
    }
    
    open func getSteps(_ fromStartDate: Date, toEndDate: Date, onRetrieve: (([Date : Int]) -> Void)?, onFailure:  ((Error?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else {
            if let failBlock = onFailure
            {
                failBlock(nil)
            }
            return
        }
        
        let calendar = Calendar.current
        let startDateComponents = (calendar as NSCalendar).components([.era, .year, .month, .day], from: fromStartDate)
        (startDateComponents as NSDateComponents).calendar = calendar
        let endDateComponents = (calendar as NSCalendar).components([.era, .year, .month, .day], from: toEndDate)
        (endDateComponents as NSDateComponents).calendar = calendar
        let startDate = calendar.date(from: startDateComponents)
        let endDate = calendar.date(from: endDateComponents)
        
        guard startDate != nil && endDate != nil else { return }
        
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: startDate!, end: (calendar as NSCalendar).date(byAdding: .day, value: 1, to: endDate!, options: NSCalendar.Options(rawValue: 0)), options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        
        if let store = healthStore, let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        {
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: dateRangePredicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: startDate!,
                                                    intervalComponents: interval)
            
            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in
                
                if let r = results , error == nil
                {
                    var stepsCollection = [Date : Int]()
                    
                    r.enumerateStatistics(from: startDate!, to: endDate!) {
                        statistics, stop in
                        
                        if let quantity = statistics.sumQuantity() {
                            
                            var steps: Int = 0
                            if let prev = stepsCollection[statistics.startDate]
                            {
                                steps = prev
                            }
                            
                            steps += Int(quantity.doubleValue(for: HKUnit.count()))
                            stepsCollection[statistics.startDate] = steps
                        }
                    }
                    
                    if let successBlock = onRetrieve
                    {
                        successBlock(stepsCollection)
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
            
            store.execute(query)
        }
    }

    open func authorizeForSteps(_ onAuthorized: (() -> (Void))?, onFailure: (() -> (Void))?)
    {
        if let store = healthStore, let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) , HKHealthStore.isHealthDataAvailable()
        {
            store.requestAuthorization(toShare: nil, read: [stepType], completion: {
                (success: Bool, error: Error?) in
                if let successBlock = onAuthorized , success
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
    
    open func initializeBackgroundQueries()
    {
        if let store = healthStore , observerQueries != nil
        {
            let stepsIdenitifier = HKQuantityTypeIdentifier.stepCount
            let stepsType = HKQuantityType.quantityType(forIdentifier: stepsIdenitifier)
            
            if let sampleType = stepsType
            {
                if let stepsQuery = observerQueries!["steps"]
                {
                    store.stop(stepsQuery)
                    observerQueries!.removeValue(forKey: stepsIdenitifier.rawValue)
                }
                
                let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: {
                    [weak self] (updateQuery: HKObserverQuery, handler: HKObserverQueryCompletionHandler, updateError: Error?) in
                    
                    //NSLog("Observer query fired")
                    /*
                    #if os(watchOS)
                        if #available(watchOSApplicationExtension 3.0, *) {
                            os_log("Observer query fired on watch")
                        } else {
                            // Fallback on earlier versions
                        }
                    #endif
                    */
                    
                    self?.getSteps(Date(),
                        onRetrieve: {
                            (steps: Int, forDay: Date) in
                            
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                            {
                                //NSLog(String(format: "Update complication with %d steps", steps))
                                /*
                                #if os(watchOS)
                                    if #available(watchOSApplicationExtension 3.0, *) {
                                        os_log("Update complication from watch with %d steps", steps)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                #endif
                                */
                                
                                WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
                            }
                            
                        },
                        onFailure: nil)
                    
                    
                    handler()
                    
                })
                
                observerQueries!["steps"] = query
                store.execute(query)
                
                #if os(iOS)
                    store.enableBackgroundDelivery(for: sampleType, frequency: .hourly, withCompletion: {
                        (success: Bool, error: Error?) in
                        if (success)
                        {
                            //NSLog("Background updates enabled for steps")
                        }
                    })
                #endif
            }
        }
    }
    
    open func cacheTodaysStepsAndUpdateComplication(_ onComplete: ((_ success: Bool) -> (Void))?)
    {
        getSteps(Date(),
            onRetrieve: {
                (steps: Int, forDay: Date) in
                        
                if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                {
                    //NSLog(String(format: "Fetch - update complication with %d steps", steps))
                    WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
                }
                
                if let c = onComplete
                {
                    c(true)
                }
                
            },
            onFailure: {
                (error: Error?) in
                /*
                if let e = error
                {
                    NSLog(String(format: "Fetch - error getting steps: %@", e.localizedDescription))
                }
                */
                
                if let c = onComplete
                {
                    c(false)
                }
        })
    }
}
