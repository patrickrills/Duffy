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
        let stepsCount = testStepsByHour().values.reduce(0, +)
        completionHandler(.success((day: date, steps: Steps(stepsCount))))
    }
    
    private func testStepsByHour() -> [Hour : Steps] {
        return [
            7: 340,
            8 : 765,
            9 : 900,
            10: 670,
            11: 1200,
            12: 876,
            13: 200,
            14: 987,
            15: 345,
            16: 1400,
            17: 1500,
            18: 2450,
            19: 1000,
            20: 343
        ]
    }
    
    public func getStepsByHour(for date: Date, completionHandler: @escaping (StepsByHourResult) -> ()) {
        completionHandler(.success(
            (
            day: date,
            stepsByHour: testStepsByHour()
            )
        ))
    }
    
    public func getSteps(from startDate: Date, to endDate: Date, completionHandler: @escaping (StepsByDateResult) -> ()) {
        let today = testStepsByHour().values.reduce(0, +)
        
        completionHandler(.success(
            [
                Date() : Steps(today),
                Calendar.current.date(byAdding: .day, value: -1, to: Date())! : 9939,
                Calendar.current.date(byAdding: .day, value: -2, to: Date())! : 10878,
                Calendar.current.date(byAdding: .day, value: -3, to: Date())! : 21239,
                Calendar.current.date(byAdding: .day, value: -4, to: Date())! : 12513,
                Calendar.current.date(byAdding: .day, value: -5, to: Date())! : 9592,
                Calendar.current.date(byAdding: .day, value: -6, to: Date())! : 17804,
                Calendar.current.date(byAdding: .day, value: -7, to: Date())! : 15902,
                Calendar.current.date(byAdding: .day, value: -8, to: Date())! : 9177,
                Calendar.current.date(byAdding: .day, value: -9, to: Date())! : 9943,
                Calendar.current.date(byAdding: .day, value: -10, to: Date())! : 8715,
                Calendar.current.date(byAdding: .day, value: -11, to: Date())! : 15005,
                Calendar.current.date(byAdding: .day, value: -12, to: Date())! : 10179,
                Calendar.current.date(byAdding: .day, value: -13, to: Date())! : 9562,
                Calendar.current.date(byAdding: .day, value: -14, to: Date())! : 13427,
                Calendar.current.date(byAdding: .day, value: -15, to: Date())! : 9448,
                Calendar.current.date(byAdding: .day, value: -16, to: Date())! : 11003,
                Calendar.current.date(byAdding: .day, value: -17, to: Date())! : 6181,
                Calendar.current.date(byAdding: .day, value: -18, to: Date())! : 3638,
                Calendar.current.date(byAdding: .day, value: -19, to: Date())! : 7918,
                Calendar.current.date(byAdding: .day, value: -20, to: Date())! : 10067,
                Calendar.current.date(byAdding: .day, value: -21, to: Date())! : 10159,
                Calendar.current.date(byAdding: .day, value: -22, to: Date())! : 9172,
                Calendar.current.date(byAdding: .day, value: -23, to: Date())! : 8598,
                Calendar.current.date(byAdding: .day, value: -24, to: Date())! : 7792,
                Calendar.current.date(byAdding: .day, value: -25, to: Date())! : 11700,
                Calendar.current.date(byAdding: .day, value: -26, to: Date())! : 12250,
                Calendar.current.date(byAdding: .day, value: -27, to: Date())! : 15791,
                Calendar.current.date(byAdding: .day, value: -28, to: Date())! : 13635,
                Calendar.current.date(byAdding: .day, value: -29, to: Date())! : 11227,
                Calendar.current.date(byAdding: .day, value: -30, to: Date())! : 8962,
                Calendar.current.date(byAdding: .day, value: -31, to: Date())! : 4751,
                Calendar.current.date(byAdding: .day, value: -32, to: Date())! : 9458,
                Calendar.current.date(byAdding: .day, value: -33, to: Date())! : 5508,
                Calendar.current.date(byAdding: .day, value: -34, to: Date())! : 7242,
                Calendar.current.date(byAdding: .day, value: -35, to: Date())! : 11481,
                Calendar.current.date(byAdding: .day, value: -36, to: Date())! : 10878,
                Calendar.current.date(byAdding: .day, value: -37, to: Date())! : 11239
            ]
        ))
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
        completionHandler(.success((day: date, flights: FlightsClimbed(3))))
    }
    
    public func getDistanceCovered(for date: Date, completionHandler: @escaping (DistanceForDayResult) -> ()) {
        completionHandler(.success((day: date, formatter: HKUnit.lengthFormatterUnit(from: HKUnit.mile()), distance: 4.6)))
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
    
    public func initializeBackgroundQueries() {
        if let store = healthStore, let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
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
            
            if let sampleId = updateQuery.objectType?.identifier {
                DispatchQueue.main.async {
                    if let subscriber = self?.subscribers[sampleId] {
                        subscriber.updateHandler()
                    }
                }
            }
            
            handler()
        })
        
        return query
    }
    
    private func enableBackgroundQueryOnPhone(for sampleType: HKSampleType, at frequency: HKUpdateFrequency, in store: HKHealthStore) {
        #if os(iOS)
            store.enableBackgroundDelivery(for: sampleType, frequency: frequency, withCompletion: {
                (success: Bool, error: Error?) in
                if let error = error {
                    LoggingService.log(error: error)
                }
            })
        #endif
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
