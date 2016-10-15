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
        
        if (stepCount > previousValueForDay)
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
    
    fileprivate class func convertDayToKey(_ day: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        return dateFormatter.string(from: day)
    }
}
