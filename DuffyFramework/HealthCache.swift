//
//  HealthCache.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation

open class HealthCache
{
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
            
            #if os(iOS)
                saveStepsToSharedCache(todaysKey: todaysKey, stepCount: stepCount)
            #endif
            
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
    
    fileprivate class func convertDayToKey(_ day: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        return dateFormatter.string(from: day)
    }
    
    fileprivate static let sharedGroupName = "group.com.bigbluefly.Duffy"
    
    fileprivate class func saveStepsToSharedCache(todaysKey: String, stepCount: Int)
    {
        var latestValues = [String : AnyObject]()
        latestValues["stepsCacheDay"] = todaysKey as AnyObject?
        latestValues["stepsCacheValue"] = stepCount as AnyObject?
        
        if let sharedDefaults = UserDefaults(suiteName: sharedGroupName)
        {
            if let _ = sharedDefaults.object(forKey: "stepsCache")
            {
                sharedDefaults.removeObject(forKey: "stepsCache")
            }
            
            sharedDefaults.set(latestValues, forKey: "stepsCache")
            sharedDefaults.synchronize()
        }
    }
    
    open class func getStepsFromSharedCache(forDay: Date) -> Int
    {
        var previousValueForDay: Int = 0
        
        if let sharedDefaults = UserDefaults(suiteName: sharedGroupName)
        {
            if let stepsDict = sharedDefaults.object(forKey: "stepsCache") as? [String : AnyObject]
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
        }
        
        return previousValueForDay
    }
    
    open class func getStepsDailyGoal() -> Int
    {
        if let stepsGoal = UserDefaults.standard.object(forKey: "stepsDailyGoal") as? Int
        {
            return stepsGoal
        }
        else
        {
            saveStepsGoalToCache(Constants.stepsGoalDefault)
            return Constants.stepsGoalDefault
        }
    }
    
    open class func saveStepsGoalToCache(_ stepGoal: Int)
    {
        UserDefaults.standard.set(stepGoal, forKey: "stepsDailyGoal")
        UserDefaults.standard.synchronize()
        
        //if watchos, send to phone
        #if os(watchOS)
            WCSessionService.getInstance().sendStepsGoal(goal: stepGoal)
        #endif
    }
    
    open class func incrementGoalReachedCounter()
    {
        var dates = getGoalReachedDates()
        let today = convertDayToKey(Date())
        if dates.count < 10 && !dates.contains(today)
        {
            dates.append(today)
            UserDefaults.standard.set(dates, forKey: "goalReachedDates")
        }
    }
    
    open class func getGoalReachedCount() -> Int
    {
        return getGoalReachedDates().count
    }
    
    fileprivate class func getGoalReachedDates() -> [String]
    {
        if let dates = UserDefaults.standard.object(forKey: "goalReachedDates") as? [String]
        {
            return dates;
        }
        
        return [String]()
    }
}
