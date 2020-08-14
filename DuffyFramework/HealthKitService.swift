//
//  HealthKitService.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import HealthKit

open class HealthKitService
{
    private static let instance: HealthKitService = HealthKitService()
    private var healthStore: HKHealthStore?
    private var eventDelegate: HealthEventDelegate?
    private var observerQueries = [String : HKObserverQuery]()
    private var statisticsQueries = [String : HKStatisticsCollectionQuery]()
    private var subscribers = [String : HealthKitSubscriber]()
    public private(set) var shouldRestartObservers: Bool = false
    
    init() {
        if (HKHealthStore.isHealthDataAvailable()) {
            healthStore = HKHealthStore()
        }
    }

    public class func getInstance() -> HealthKitService {
        return instance
    }
    
    public func setEventDelegate(_ delegate: HealthEventDelegate) {
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
                        HealthCache.incrementGoalReachedCounter()
                        
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
    
    public func getStepsByHour(for date: Date, completionHandler: @escaping (StepsByHourResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(), let store = healthStore else {
            completionHandler(.failure(.unsupported))
            return
        }
        
        guard let queryStartDate = getQueryDate(from: date),
            let queryEndDate = Calendar.current.date(byAdding: .day, value: 1, to: queryStartDate)
        else {
            completionHandler(.failure(.invalidQuery))
            return
        }
        
        let forSpecificDay = HKQuery.predicateForSamples(withStart: queryStartDate, end: queryEndDate, options: [])
        
        var interval = DateComponents()
        interval.hour = 1
        
        if let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        {
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: forSpecificDay,
                                                    options: .cumulativeSum,
                                                    anchorDate: queryStartDate,
                                                    intervalComponents: interval)
            
            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in
                
                if let r = results , error == nil {
                    var stepsByHour = [Hour : Steps]()
                    
                    r.enumerateStatistics(from: queryStartDate, to: queryEndDate) {
                        statistics, stop in
                        
                        if let quantity = statistics.sumQuantity() {
                            let hour = Calendar.current.component(.hour, from: statistics.startDate)
                            
                            if hour >= 0 {
                                let stepsThisHour = Steps(quantity.doubleValue(for: HKUnit.count()))
                                stepsByHour[Hour(hour)] = stepsThisHour
                            }
                        }
                    }
                    
                    completionHandler(.success((day: queryStartDate, stepsByHour: stepsByHour)))
                } else {
                    var errorResult: HealthKitError = .invalidResults
                    if let error = error {
                        errorResult = .wrapped(error)
                    }
                    completionHandler(.failure(errorResult))
                }
            }
            
            store.execute(query)
        }
    }
    
    public func getSteps(from startDate: Date, to endDate: Date, completionHandler: @escaping (StepsByDateResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(), let store = healthStore else {
            completionHandler(.failure(.unsupported))
            return
        }
        
        guard let queryStartDate = getQueryDate(from: startDate),
            let queryEndDate = getQueryDate(from: endDate)
        else {
            completionHandler(.failure(.invalidQuery))
            return
        }
        
        let endDateFilter = getQueryEndDate(fromStartDate: queryEndDate)
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: queryStartDate, end: endDateFilter, options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        
        if let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) {
            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: dateRangePredicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: queryStartDate,
                                                    intervalComponents: interval)
            
            query.initialResultsHandler = {
                (query: HKStatisticsCollectionQuery, results: HKStatisticsCollection?, error: Error?) in
                
                if let r = results , error == nil {
                    var stepsCollection = [Date : Steps]()
                    
                    r.enumerateStatistics(from: queryStartDate, to: queryEndDate) {
                        statistics, stop in
                        
                        if let quantity = statistics.sumQuantity() {
                            
                            var steps: Steps = 0
                            if let prev = stepsCollection[statistics.startDate] {
                                steps = prev
                            }
                            
                            steps += Steps(quantity.doubleValue(for: HKUnit.count()))
                            stepsCollection[statistics.startDate] = steps
                        }
                    }
                    
                    completionHandler(.success(stepsCollection))
                }
                else
                {
                    var errorResult: HealthKitError = .invalidResults
                    if let error = error {
                        errorResult = .wrapped(error)
                    }
                    completionHandler(.failure(errorResult))
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
                if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                    readDataTypes.insert(distanceType)
                }
                
                if let flightType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) {
                    readDataTypes.insert(flightType)
                }
                
                if let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    readDataTypes.insert(activeType)
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
        if let store = healthStore, let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        {
            DispatchQueue.main.async {
                self.shouldRestartObservers = false
            }
            
            let stepsKey = "steps"
            
            #if os(iOS)
                LoggingService.log("App is starting observers")
            
                let query = createObserverQuery(key: stepsKey, sampleType: stepsType, store: store)
                observerQueries[stepsKey] = query
                store.execute(query)
                enableBackgroundQueryOnPhone(for: stepsType, at: .hourly, in: store)

                if let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    let key = "activeEnergy"
                    let query = createObserverQuery(key: key, sampleType: activeType, store: store)
                    observerQueries[key] = query
                    store.execute(query)
                    enableBackgroundQueryOnPhone(for: activeType, at: .immediate, in: store)
                }
            #elseif os(watchOS)
                LoggingService.log("App is starting stats queries")
            
                if let statsQuery = createUpdatingStatisticsQuery(key: stepsKey, quantityType: stepsType, store: store) {
                    statisticsQueries[stepsKey] = statsQuery
                    store.execute(statsQuery)
                }
            #endif
        }
    }
    
    open func stopBackgroundQueries() {
        guard let healthStore = healthStore else { return }
        
        observerQueries.forEach({
            healthStore.stop($1)
        })
        observerQueries.removeAll()
        
        statisticsQueries.forEach({
            healthStore.stop($1)
        })
        statisticsQueries.removeAll()
    }
    
    private func createObserverQuery(key: String, sampleType: HKSampleType, store: HKHealthStore) -> HKObserverQuery
    {
        if let oldQuery = observerQueries[key]
        {
            store.stop(oldQuery)
            observerQueries.removeValue(forKey: key)
        }
        
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil, updateHandler: {
            [weak self] (updateQuery: HKObserverQuery, handler: HKObserverQueryCompletionHandler, updateError: Error?) in
            
            if let updateError = updateError {
                LoggingService.log(error: updateError)
                let nsUpdateError = updateError as NSError
                //Error code 5 is 'authorization not determined'. Permission hasn't been granted yet
                if nsUpdateError.code == 5 && nsUpdateError.domain == "com.apple.healthkit" {
                    DispatchQueue.main.async {
                        self?.shouldRestartObservers = true
                    }

                    handler()
                    return
                }
            }
            
            self?.getSteps(Date(),
                onRetrieve: {
                    (steps: Int, forDay: Date) in
                    
                    LoggingService.log(String(format: "Steps retrieved by %@ observer", key), with: String(format: "%d", steps))
                    
                    if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                    {
                        LoggingService.log(String(format: "updateWatchFaceComplication from %@ observer", key), with: String(format: "%d", steps))
                        WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
                    }
                },
                onFailure: nil)
            
            if let sampleId = updateQuery.objectType?.identifier,
                let subscriber = self?.subscribers[sampleId] {
                subscriber.updateHandler()
            }
            
            handler()
        })
        
        return query
    }
    
    private func enableBackgroundQueryOnPhone(for sampleType: HKSampleType, at frequency: HKUpdateFrequency, in store: HKHealthStore)
    {
        #if os(iOS)
            store.enableBackgroundDelivery(for: sampleType, frequency: frequency, withCompletion: {
                (success: Bool, error: Error?) in
                if let error = error {
                    LoggingService.log(error: error)
                }
            })
        #endif
    }
    
    private func createUpdatingStatisticsQuery(key: String, quantityType: HKQuantityType, store: HKHealthStore) -> HKStatisticsCollectionQuery?
    {
        if let oldQuery = statisticsQueries.removeValue(forKey: key) {
            store.stop(oldQuery)
        }
        
        let today = getQueryDate(from: Date())
        guard let sinceDate = today else { return nil }
        
        var interval = DateComponents()
        interval.day = 1
        
        let statsQuery = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: sinceDate,
                                                intervalComponents: interval)
        
        let resultsHandler: (HKStatisticsCollectionQuery, HKStatisticsCollection?, Error?) -> Void = { [weak self] query, results, error in
            if let results = results,
                error == nil,
                let startDate = self?.getQueryDate(from: Date()),
                let endDate = self?.getQueryEndDate(fromStartDate: startDate)
            {
                var todaysSteps: Int = 0
                
                results.enumerateStatistics(from: startDate, to: endDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        todaysSteps += Int(quantity.doubleValue(for: HKUnit.count()))
                    }
                }
                
                LoggingService.log(String(format: "Steps retrieved by %@ stats query", key), with: String(format: "%d", todaysSteps))
                
                if (HealthCache.saveStepsToCache(todaysSteps, forDay: startDate)) {
                    LoggingService.log(String(format: "updateWatchFaceComplication from %@ stats query", key), with: String(format: "%d", todaysSteps))
                    WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
                }
                
                if todaysSteps >= HealthCache.getStepsDailyGoal(),
                    NotificationService.convertDayToKey(startDate) == NotificationService.convertDayToKey(Date())
                {
                    HealthCache.incrementGoalReachedCounter()
                    
                    if let del = self?.eventDelegate {
                        del.dailyStepsGoalWasReached()
                    }
                }
                
                if let sampleId = query.objectType?.identifier,
                    let subscriber = self?.subscribers[sampleId]
                {
                    subscriber.updateHandler()
                }
            }
            else if let error = error
            {
                LoggingService.log(error: error)
                
                let nsUpdateError = error as NSError
                //Error code 5 is 'authorization not determined'. Permission hasn't been granted yet
                if nsUpdateError.code == 5 && nsUpdateError.domain == "com.apple.healthkit" {
                    DispatchQueue.main.async {
                        self?.shouldRestartObservers = true
                    }
                }
            }
        }
        
        statsQuery.initialResultsHandler = resultsHandler
        statsQuery.statisticsUpdateHandler = { query, stats, results, error in
            resultsHandler(query, results, error)
        }
        
        return statsQuery
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
    
    open func subscribe(to dataType: HKQuantityTypeIdentifier, on updateHandler: @escaping (() -> Void)) {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: dataType) else {
            return
        }
        
        subscribers.removeValue(forKey: sampleType.identifier)
        subscribers[sampleType.identifier] = HealthKitSubscriber(for: dataType, with: updateHandler)
    }
    
    open func unsubscribe(from dataType: HKQuantityTypeIdentifier) {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: dataType) else {
            return
        }
        
        subscribers.removeValue(forKey: sampleType.identifier)
    }
    
    open func earliestQueryDate() -> Date? {
        return healthStore?.earliestPermittedSampleDate()
    }
}

class HealthKitSubscriber {
    var sampleTypeIdentifier: HKQuantityTypeIdentifier
    var updateHandler: (() -> Void)
    
    init(for sampleType: HKQuantityTypeIdentifier, with updateHandler: @escaping (() -> Void)) {
        self.sampleTypeIdentifier = sampleType
        self.updateHandler = updateHandler
    }
}
