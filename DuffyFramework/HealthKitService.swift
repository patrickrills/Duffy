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
    
    //MARK: Variables
    
    private static let instance: HealthKitService = HealthKitService()
    private var healthStore: HKHealthStore?
    private var observerQueries = [String : HKObserverQuery]()
    private var statisticsQueries = [String : HKStatisticsCollectionQuery]()
    private var subscribers = [String : HealthKitSubscriber]()
    public private(set) var shouldRestartObservers: Bool = false
    
    //MARK: Constructors
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    public class func getInstance() -> HealthKitService {
        return instance
    }
    
    //MARK: Authorize HealthKit
    
    public func authorize(completionHandler: @escaping (Bool) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(),
            let store = healthStore,
            let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount),
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            let flightType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed),
            let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        else {
            completionHandler(false)
            return
        }
        
        let readDataTypes: Set<HKObjectType> = [stepType, distanceType, flightType, activeType]
        store.requestAuthorization(toShare: nil, read: readDataTypes) { success, error in
            completionHandler(success && error == nil)
        }
    }
    
    //MARK: Steps Queries

    public func getSteps(for date: Date, completionHandler: @escaping (StepsForDayResult) -> ())
    {
        guard HKHealthStore.isHealthDataAvailable(),
            let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        else { return }
        
        get(quantityType: stepType, measuredIn: HKUnit.count(), on: date) { result in
            switch result {
            case .success(let sumValue):
                let steps = Steps(sumValue.sum)
                StepsProcessingService.handleSteps(steps, for: sumValue.day, from: "steps for day query")
                completionHandler(.success((day: sumValue.day, steps: steps)))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    public func getStepsByHour(for date: Date, completionHandler: @escaping (StepsByHourResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(), let store = healthStore else {
            completionHandler(.failure(.unsupported))
            return
        }
        
        let queryStartDate = date.stripTime()
        let queryEndDate = queryStartDate.nextDay()
        
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
        
        let queryStartDate = startDate.stripTime()
        let queryEndDate = endDate.stripTime().nextDay()
    
        let dateRangePredicate = HKQuery.predicateForSamples(withStart: queryStartDate, end: queryEndDate, options: .strictEndDate)
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
    
    public func lastTrophiesAwarded(completionHandler: @escaping (LastTrophyAwardResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(),
              let store = healthStore,
              let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        else {
            completionHandler(.failure(.unsupported))
            return
        }
        
        let queryStartDate = Date().dateByAdding(days: -730).stripTime() //Cap to previous 2 years
        let pred = HKQuery.predicateForSamples(withStart: queryStartDate, end: Date().nextDay().stripTime(), options: .strictEndDate)
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                quantitySamplePredicate: pred,
                                                options: .cumulativeSum,
                                                anchorDate: Date().stripTime(),
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            let max = Trophy.allCases.filter { $0 != .none }.count
            var awards = [Trophy : LastAward]()
            var loopDate = Date().stripTime()
            
            guard let results = results,
                  error == nil
            else {
                completionHandler(.failure(.invalidResults))
                return
            }
            
            while loopDate > queryStartDate,
                  awards.count < max
            {
                if let stats = results.statistics(for: loopDate),
                   let quantity = stats.sumQuantity(),
                   case let sum = Steps(quantity.doubleValue(for: .count())),
                   case let trophy = Trophy.trophy(for: sum),
                   trophy != .none,
                   !awards.keys.contains(trophy)
                {
                    awards[trophy] = (day: loopDate, steps: sum)
                }
                
                loopDate = loopDate.dateByAdding(days: -1)
            }
            
            completionHandler(.success(awards))
        }
        
        store.execute(query)
    }
    
    //MARK: Flights and Distance Queries
        
    public func getFlightsClimbed(for date: Date, completionHandler: @escaping (FlightsForDayResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(),
            let flightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        else { return }
        
        get(quantityType: flightType, measuredIn: HKUnit.count(), on: date) { result in
            switch result {
            case .success(let sumValue):
                completionHandler(.success((day: sumValue.day, flights: FlightsClimbed(sumValue.sum))))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    public func getDistanceCovered(for date: Date, completionHandler: @escaping (DistanceForDayResult) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(),
            let store = healthStore,
            let distanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        else { return }
        
        store.preferredUnits(for: [distanceType]) { [weak self] units, error in
            if let error = error {
                completionHandler(.failure(.wrapped(error)))
                return
            }
            
            var distanceUnits = HKUnit.mile()
            if let preferred = units[distanceType] {
                distanceUnits = preferred
            }
            
            self?.get(quantityType: distanceType, measuredIn: distanceUnits, on: date) { result in
                switch result {
                case .success(let sumValue):
                    completionHandler(.success((day: sumValue.day, formatter: HKUnit.lengthFormatterUnit(from: distanceUnits), distance: sumValue.sum)))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    //MARK: Helpers
    
    private func get(quantityType: HKQuantityType, measuredIn: HKUnit, on: Date, completionHandler: @escaping (Result<(day: Date, sum: Double), HealthKitError>) -> ()) {
        guard HKHealthStore.isHealthDataAvailable(), let store = healthStore else { return }
        
        let startDate = on.stripTime()
        let endDate = startDate.nextDay()
        
        let forSpecificDay = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: forSpecificDay,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: interval)
            
        query.initialResultsHandler = { query, results, error in
            if let r = results , error == nil {
                var sum: Double = 0.0
                var sampleDate: Date = Date.distantPast
                    
                r.enumerateStatistics(from: query.anchorDate, to: query.anchorDate) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        sampleDate = statistics.startDate
                        sum += quantity.doubleValue(for: measuredIn)
                    }
                }
                
                completionHandler(.success((day: sampleDate, sum: sum)))
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
    
    public func earliestQueryDate() -> Date? {
        return healthStore?.earliestPermittedSampleDate()
    }
}

//MARK: Observing

extension HealthKitService {
    
    private static let stepsKey = "steps"
    
    public func initializeBackgroundQueries() {
        if let store = healthStore,
            let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        {
            DispatchQueue.main.async {
                self.shouldRestartObservers = false
            }
            
            #if os(iOS)
                createStepsObserverQuery(with: Self.stepsKey, for: stepsType, in: store)

                if let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    let key = "activeEnergy"
                    let query = createObserverQuery(key: key, sampleType: activeType, store: store)
                    observerQueries[key] = query
                    store.execute(query)
                    enableBackgroundQuery(for: activeType, at: .immediate, in: store)
                }
            #elseif os(watchOS)
                if #available(watchOS 8.0, *) {
                    createStepsObserverQuery(with: Self.stepsKey, for: stepsType, in: store)
                } else {
                    startUIUpdatingQueries()
                }
            #endif
        }
    }
    
    public func stopBackgroundQueries() {
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
    
    private func startUIUpdatingQueries() {
        guard let healthStore = healthStore,
              let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else {
            return
        }
        
        LoggingService.log("App is starting stats queries")
    
        if let statsQuery = createUpdatingStatisticsQuery(key: Self.stepsKey, quantityType: stepsType, store: healthStore) {
            statisticsQueries[Self.stepsKey] = statsQuery
            healthStore.execute(statsQuery)
        }
    }
    
    @available(watchOSApplicationExtension 8.0, *)
    private func createStepsObserverQuery(with key: String, for type: HKQuantityType, in store: HKHealthStore) {
        LoggingService.log("App is starting observers")
        let query = createObserverQuery(key: key, sampleType: type, store: store)
        observerQueries[key] = query
        store.execute(query)
        enableBackgroundQuery(for: type, at: .hourly, in: store)
    }
    
    private func createObserverQuery(key: String, sampleType: HKSampleType, store: HKHealthStore) -> HKObserverQuery {
        if let oldQuery = observerQueries[key] {
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
            
            self?.getSteps(for: Date()) { result in
                switch result {
                case .success(let stepsResult):
                    LoggingService.log(String(format: "Steps retrieved by %@ observer", key), with: String(format: "%d", stepsResult.steps))
                case .failure(let error):
                    LoggingService.log(error: error)
                }
            }
            
            handler()
        })
        
        return query
    }
    
    //TODO: Need to enable new iOS 15 entitlement for HealthKit background delivery in provisioning profile
    //  [Duffy] Phone Error: Missing com.apple.developer.healthkit.background-delivery entitlement. (4)
    @available(watchOSApplicationExtension 8.0, *)
    private func enableBackgroundQuery(for sampleType: HKSampleType, at frequency: HKUpdateFrequency, in store: HKHealthStore) {
        store.enableBackgroundDelivery(for: sampleType, frequency: frequency, withCompletion: {
            (success: Bool, error: Error?) in
            if let error = error {
                LoggingService.log(error: error)
            }
        })
    }
    
    private func createUpdatingStatisticsQuery(key: String, quantityType: HKQuantityType, store: HKHealthStore) -> HKStatisticsCollectionQuery? {
        if let oldQuery = statisticsQueries.removeValue(forKey: key) {
            store.stop(oldQuery)
        }
        
        let sinceDate = Date().stripTime()
        
        var interval = DateComponents()
        interval.day = 1
        
        let statsQuery = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: sinceDate,
                                                intervalComponents: interval)
        
        let resultsHandler: (HKStatisticsCollectionQuery, HKStatisticsCollection?, Error?) -> Void = { [weak self] query, results, error in
            if let results = results,
                error == nil
            {
                var todaysSteps: Steps = 0
                let startDate = Date().stripTime()
                
                results.enumerateStatistics(from: startDate, to: startDate.nextDay()) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        todaysSteps += Steps(quantity.doubleValue(for: HKUnit.count()))
                    }
                }
                
                let source = String(format: "%@ stats query", key)
                LoggingService.log(String(format: "Steps retrieved by %@", source), with: String(format: "%d", todaysSteps))
                
                StepsProcessingService.handleSteps(todaysSteps, for: startDate, from: source)
                
                if let sampleId = query.objectType?.identifier,
                    let subscriber = self?.subscribers[sampleId]
                {
                    LoggingService.log(String(format: "Update UI from %@", source), with: String(format: "%d", todaysSteps))
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
    
    public func subscribe(to dataType: HKQuantityTypeIdentifier, on updateHandler: @escaping (() -> Void)) {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: dataType) else {
            return
        }
        
        startUIUpdatingQueries()
                
        subscribers.removeValue(forKey: sampleType.identifier)
        subscribers[sampleType.identifier] = HealthKitSubscriber(for: dataType, with: updateHandler)
    }
    
    public func unsubscribe(from dataType: HKQuantityTypeIdentifier) {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: dataType) else {
            return
        }
        
        subscribers.removeValue(forKey: sampleType.identifier)
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
