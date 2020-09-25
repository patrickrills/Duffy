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
        case stepsDailyGoal = "stepsDailyGoal"
        case goalReachedDates = "goalReachedDates"
        
        static let sharedGroupName = "group.com.bigbluefly.Duffy"
    }
    
    @discardableResult
    open class func saveStepsToCache(_ stepCount: Int, forDay: Date) -> Bool
    {
        let todaysKey = convertDayToKey(forDay)
        let previousValueForDay = getStepsFromCache(forDay)
        
        if (stepCount > previousValueForDay || cacheIsForADifferentDay(forDay))
        {
            var latestValues = [String : AnyObject]()
            latestValues["stepsCacheDay"] = todaysKey as AnyObject?
            latestValues["stepsCacheValue"] = stepCount as AnyObject?
            
            if let _ = UserDefaults.standard.object(forKey: "stepsCache")
            {
                UserDefaults.standard.removeObject(forKey: "stepsCache")
            }
            
            UserDefaults.standard.set(latestValues, forKey: "stepsCache")
            UserDefaults.standard.synchronize()
            
            LoggingService.log("Save steps to cache", with: String(format: "%d", stepCount))
            
            return true
        }
        
        return false
    }
    
    open class func saveStepsDataToCache(_ data : [String : AnyObject]) -> Bool
    {
        if let dayKey = data["stepsCacheDay"] as? String
        {
            if (dayKey == convertDayToKey(Date()))
            {
                if let stepsCount = data["stepsCacheValue"] as? Int
                {
                    return saveStepsToCache(stepsCount, forDay: Date())
                }
            }
        }
        
        return false
    }
    
    open class func getStepsFromCache(_ forDay: Date) -> Int
    {
        var previousValueForDay: Int = 0
        
        if let stepsDict = UserDefaults.standard.object(forKey: "stepsCache") as? [String : AnyObject]
        {
            if let previousDay = stepsDict["stepsCacheDay"] as? String
            {
                if (previousDay == convertDayToKey(forDay))
                {
                    if let prev = stepsDict["stepsCacheValue"] as? Int
                    {
                        previousValueForDay = prev
                    }
                }
            }
        }
        
        return previousValueForDay
    }
    
    open class func getStepsDataFromCache() -> [String : AnyObject]
    {
        if let stepsDict = UserDefaults.standard.object(forKey: "stepsCache") as? [String : AnyObject]
        {
            return stepsDict
        }
        
        return ["stepsCacheDay" : convertDayToKey(Date()) as AnyObject, "stepsCacheValue" : Int(0) as AnyObject]
    }
    
    open class func cacheIsForADifferentDay(_ currentDay: Date) -> Bool
    {
        if let stepsDict = UserDefaults.standard.object(forKey: "stepsCache") as? [String : AnyObject]
        {
            if let previousDay = stepsDict["stepsCacheDay"] as? String
            {
                return (previousDay != convertDayToKey(currentDay))
            }
        }
        
        return true
    }
    
    //MARK: Retrieving and saving the goal
        
    public class func dailyGoal() -> Steps {
        guard let stepsGoal = UserDefaults.standard.object(forKey: CacheKeys.stepsDailyGoal.rawValue) as? Steps else {
            saveStepsGoalToCache(Int(Constants.stepsGoalDefault)) //TODO: remove Int cast
            return Constants.stepsGoalDefault
        }
        
        return stepsGoal
    }
    
    open class func getStepsDailyGoalFromShared() -> Int
    {
        #if os(iOS)
            if let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName),
                let goal = sharedDefaults.object(forKey: "stepsDailyGoal") as? Int {
                    return goal
            } else {
                return 0
            }
        #else
            return Int(dailyGoal()) //TODO: remove Int cast
        #endif
    }
    
    open class func saveStepsGoalToCache(_ stepGoal: Int)
    {
        UserDefaults.standard.set(stepGoal, forKey: "stepsDailyGoal")
        
        #if os(iOS)
            if let sharedDefaults = UserDefaults(suiteName: CacheKeys.sharedGroupName) {
                sharedDefaults.set(stepGoal, forKey: "stepsDailyGoal")
            }
        #endif
        
        //if watchos, send to phone
        #if os(watchOS)
            WCSessionService.getInstance().sendStepsGoal(goal: stepGoal)
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
