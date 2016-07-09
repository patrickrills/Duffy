//
//  HealthCache.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation

class HealthCache
{
    class func saveStepsToCache(stepCount: Int, forDay: NSDate) -> Bool
    {
        let todaysKey = convertDayToKey(forDay)
        let previousValueForDay = getStepsFromCache(forDay)
        
        if (stepCount > previousValueForDay)
        {
            var latestValues = [String : AnyObject]()
            latestValues["stepsCacheDay"] = todaysKey
            latestValues["stepsCacheValue"] = stepCount
            
            if let _ = NSUserDefaults.standardUserDefaults().objectForKey("stepsCache")
            {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("stepsCache")
            }
            
            NSUserDefaults.standardUserDefaults().setObject(latestValues, forKey: "stepsCache")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            return true
        }
        
        return false
    }
    
    class func getStepsFromCache(forDay: NSDate) -> Int
    {
        var previousValueForDay: Int = 0
        
        if let stepsDict = NSUserDefaults.standardUserDefaults().objectForKey("stepsCache") as? [String : AnyObject]
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
    
    private class func convertDayToKey(day: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        return dateFormatter.stringFromDate(day)
    }
}