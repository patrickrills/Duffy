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

        let startDate = getQueryDate(from: forDate)
        guard startDate != nil else { return }

        let forSpecificDay = HKQuery.predicateForSamples(withStart: startDate!, end: getQueryEndDate(fromStartDate: startDate!), options: [])
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
                [weak self] (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in

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
                    
                    if steps >= HealthCache.getStepsDailyGoal(),
                        NotificationService.convertDayToKey(sampleDate) == NotificationService.convertDayToKey(Date())
                    {
                        if let del = self?.eventDelegate
                        {
                            del.dailyStepsGoalWasReached()
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
    
    open func getSteps(_ fromStartDate: Date, toEndDate: Date, onRetrieve: (([Date : Int]) -> Void)?, onFailure: ((Error?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else {
            if let failBlock = onFailure
            {
                failBlock(nil)
            }
            return
        }
        
        let startDate = getQueryDate(from: fromStartDate)
        let endDate = getQueryDate(from: toEndDate)
        
        guard startDate != nil && endDate != nil else { return }
        
        let endDateFilter = getQueryEndDate(fromStartDate: endDate!)
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: startDate!, end: endDateFilter, options: .strictEndDate)
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
        authorize(onAuthorized, onFailure: onFailure, includeExtraTypes: false)
    }
    
    open func authorizeForAllData(_ onAuthorized: (() -> (Void))?, onFailure: (() -> (Void))?)
    {
        authorize(onAuthorized, onFailure: onFailure, includeExtraTypes: true)
    }

    open func authorize(_ onAuthorized: (() -> (Void))?, onFailure: (() -> (Void))?, includeExtraTypes: Bool)
    {
        if let store = healthStore, let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) , HKHealthStore.isHealthDataAvailable()
        {
            var readDataTypes = Set<HKObjectType>()
            readDataTypes.insert(stepType)
            
            if (includeExtraTypes)
            {
                if let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
                {
                    readDataTypes.insert(distanceType)
                }
                
                if let flightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
                {
                    readDataTypes.insert(flightType)
                }
            }
            
            store.requestAuthorization(toShare: nil, read: readDataTypes, completion: {
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
                    
                    self?.getSteps(Date(),
                        onRetrieve: {
                            (steps: Int, forDay: Date) in
                            
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                            {
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
                if let c = onComplete
                {
                    c(false)
                }
        })
    }
    
    open func getAdornment(for stepsTotal: Int) -> String
    {
        let stepsGoal = Double(HealthCache.getStepsDailyGoal())
        let steps = Double(stepsTotal)
        
        if steps >= (stepsGoal * 1.5) {
            return "🏆"
        } else if steps >= (stepsGoal * 1.25) {
            return "🏅"
        } else if steps >= stepsGoal {
            return "👟"
        }
        
        return ""
    }
    
    open func getFlightsClimbed(_ forDate: Date, onRetrieve: ((Int, Date) -> Void)?, onFailure: ((Error?) -> Void)?)
    {
        if let flightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        {
            get(quantityType: flightType, measuredIn: HKUnit.count(), on: forDate, onRetrieve: { flightsClimbed, onDate in
                if let success = onRetrieve
                {
                    success(Int(flightsClimbed), onDate)
                }
            }, onFailure: onFailure)
        }
        else if let fail = onFailure
        {
            fail(nil)
        }
    }
    
    open func getDistanceCovered(_ forDate: Date, onRetrieve: ((Double, LengthFormatter.Unit, Date) -> Void)?, onFailure: ((Error?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else { return }
        
        if let store = healthStore, let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        {
            store.preferredUnits(for: [distanceType], completion: {
                [weak self] units, error in
                if let e = error
                {
                    if let fail = onFailure
                    {
                        fail(e)
                    }
                    
                    return
                }
                else
                {
                    var distanceUnits = HKUnit.mile()
                    if let preferred = units[distanceType]
                    {
                        distanceUnits = preferred
                    }
                    
                    let units = HKUnit.lengthFormatterUnit(from: distanceUnits)
                    
                    self?.get(quantityType: distanceType, measuredIn: distanceUnits, on: forDate, onRetrieve: {
                        distance, date in
                        if let success = onRetrieve
                        {
                            success(distance, units, date)
                        }
                    }, onFailure: onFailure)
                }
            })
        }
        else if let fail = onFailure
        {
            fail(nil)
        }
    }
    
    open func get(quantityType: HKQuantityType, measuredIn: HKUnit, on: Date, onRetrieve: ((Double, Date) -> Void)?, onFailure: ((Error?) -> Void)?)
    {
        guard HKHealthStore.isHealthDataAvailable() && healthStore != nil else { return }
        
        let startDate = getQueryDate(from: on)
        guard startDate != nil else { return }
        
        let forSpecificDay = HKQuery.predicateForSamples(withStart: startDate!, end: getQueryEndDate(fromStartDate: startDate!), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        if let store = healthStore
        {
            let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                    quantitySamplePredicate: forSpecificDay,
                                                    options: .cumulativeSum,
                                                    anchorDate: startDate!,
                                                    intervalComponents: interval)
            
            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in
                
                if let r = results , error == nil
                {
                    var sum: Double = 0.0
                    var sampleDate: Date = Date.distantPast
                    
                    r.enumerateStatistics(from: query.anchorDate, to: query.anchorDate) { statistics, stop in
                        if let quantity = statistics.sumQuantity()
                        {
                            sampleDate = statistics.startDate
                            sum += quantity.doubleValue(for: measuredIn)
                        }
                    }
                    
                    if let successBlock = onRetrieve
                    {
                        successBlock(sum ,sampleDate)
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
    
    private func getQueryDate(from: Date) -> Date?
    {
        let components = Calendar.current.dateComponents([.era, .year, .month, .day], from: from)
        return Calendar.current.date(from: components)
    }
    
    private func getQueryEndDate(fromStartDate: Date) -> Date
    {
        return Calendar.current.date(byAdding: .day, value: 1, to: fromStartDate)!
    }
}
