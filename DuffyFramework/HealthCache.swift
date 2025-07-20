//
//  HealthCache.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation

public class HealthCache {
    
    private enum CacheKeys: String {
        case stepsCache = "stepsCache"
        case stepsCacheValue = "stepsCacheValue"
        case stepsCacheDay = "stepsCacheDay"
        case stepsDailyGoal = "stepsDailyGoal"
        case goalReachedDates = "goalReachedDates"
        
        static let sharedGroupName = "group.com.bigbluefly.Duffy"
    }
    
    private typealias CachedSteps = (steps: Steps, day: String)
    
    @discardableResult
    public class func saveStepsToCache(_ stepCount: Steps, for day: Date) -> Bool {
        var saved: Bool = false
        
        if let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName) {
            saved = saveSteps(stepCount, for: day, to: sharedDefaults)
        }
        
        if !saved {
            saved = saveSteps(stepCount, for: day, to: UserDefaults.standard)
        }
        
        return saved
    }
    
    private class func saveSteps(_ stepCount: Steps, for day: Date, to userDefaults: UserDefaults) -> Bool {
        let todaysKey = convertDayToKey(day)
        let previousValueForDay = lastSteps(for: day)
        
        if stepCount > previousValueForDay || cacheIsForADifferentDay(than: day) {
            var latestValues: [String : AnyObject] = [:]
            latestValues[CacheKeys.stepsCacheDay.rawValue] = todaysKey as AnyObject
            latestValues[CacheKeys.stepsCacheValue.rawValue] = stepCount as AnyObject
            userDefaults.removeObject(forKey: CacheKeys.stepsCache.rawValue)
            userDefaults.set(latestValues, forKey: CacheKeys.stepsCache.rawValue)
    
            LoggingService.log("Save steps to cache", with: String(format: "%d", stepCount))
            
            return true
        } else {
            return false
        }
    }
    
    public class func lastSteps(for day: Date) -> Steps {
        guard let cache = cache(),
              cache.day == convertDayToKey(day)
        else {
            return 0
        }
        
        return cache.steps
    }
    
    public class func cacheIsForADifferentDay(than day: Date) -> Bool {
        guard let cache = cache() else {
            return true
        }
        
        return cache.day != convertDayToKey(day)
    }
    
    private class func cache() -> CachedSteps? {
        guard let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName),
            let sharedCache = retrieveCache(from: sharedDefaults)
        else {
            return retrieveCache(from: UserDefaults.standard)
        }
        
        return sharedCache
    }
    
    private class func retrieveCache(from userDefaults: UserDefaults) -> CachedSteps? {
        guard let stepsDict = userDefaults.object(forKey: CacheKeys.stepsCache.rawValue) as? [String : AnyObject],
            let cache = parse(dictionary: stepsDict)
        else {
            return nil
        }
        
        return cache
    }
    
    private class func parse(dictionary: [String : AnyObject]) -> CachedSteps? {
        guard
            let cachedSteps = dictionary[CacheKeys.stepsCacheValue.rawValue] as? Steps,
            let cachedDay = dictionary[CacheKeys.stepsCacheDay.rawValue] as? String
        else {
            return nil
        }
        
        return CachedSteps(steps: cachedSteps, day: cachedDay)
    }
    
    //MARK: Retrieving and saving the goal
        
    public class func dailyGoal() -> Steps {
        //Attempt to grab it from shared store first
        if let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName),
           let sharedGoal = sharedDefaults.object(forKey: CacheKeys.stepsDailyGoal.rawValue) as? Steps
        {
            return sharedGoal
        }
        
        //See if it is stored locally next (legacy)
        if let stepsGoal = UserDefaults.standard.object(forKey: CacheKeys.stepsDailyGoal.rawValue) as? Steps {
            saveDailyGoal(stepsGoal)
            return stepsGoal
        }
        
        //Return default
        saveDailyGoal(Constants.stepsGoalDefault)
        return Constants.stepsGoalDefault
    }
    
    public class func saveDailyGoal(_ dailyStepGoal: Steps)
    {
        if let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName) {
            sharedDefaults.set(dailyStepGoal, forKey: CacheKeys.stepsDailyGoal.rawValue)
        } else {
            UserDefaults.standard.set(dailyStepGoal, forKey: CacheKeys.stepsDailyGoal.rawValue)
        }
        
        //if watchos, send to phone
        #if os(watchOS)
            WCSessionService.getInstance().sendStepsGoal(goal: dailyStepGoal)
        #endif
    }
    
    public class func incrementGoalReachedCounter() {
        var dates = getGoalReachedDates()
        let today = convertDayToKey(Date())
        if dates.count < 10 && !dates.contains(today) {
            dates.append(today)
            UserDefaults.standard.set(dates, forKey: CacheKeys.goalReachedDates.rawValue)
        }
    }
    
    public class func getGoalReachedCount() -> Int {
        return getGoalReachedDates().count
    }
    
    private class func getGoalReachedDates() -> [String] {
        guard let goalReachedDates = UserDefaults.standard.object(forKey: CacheKeys.goalReachedDates.rawValue) as? [String] else {
            return []
        }
        
        return goalReachedDates
    }
    
    private class func convertDayToKey(_ day: Date) -> String {
        return keyDayFormatter.string(from: day)
    }
    
    private static var keyDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        return dateFormatter
    }()
}
