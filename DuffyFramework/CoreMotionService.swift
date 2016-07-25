//
//  CoreMotionService.swift
//  Duffy
//
//  Created by Patrick Rills on 7/24/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import CoreMotion

public class CoreMotionService
{
    static let instance = CoreMotionService()
    var pedometer: CMPedometer?
    
    init()
    {
        if (CMPedometer.isStepCountingAvailable())
        {
            pedometer = CMPedometer()
        }
    }
    
    public class func getInstance() -> CoreMotionService
    {
        return instance
    }
    
    public func initializeBackgroundUpdates()
    {
        if let ped = pedometer
        {
            ped.startPedometerUpdatesFromDate(NSDate(), withHandler: {
                data, error in
                if let stepData = data {
                    
                    NSLog("CMPedometer - Steps Taken: \(stepData.numberOfSteps)")
                    
                    HealthKitService.getInstance().getSteps(NSDate(),
                        onRetrieve: {
                            (steps: Int, forDay: NSDate) in
                            
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                            {
                                NSLog(String(format: "Update complication from CMPedometer with %d steps", steps))
                                WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache()])
                            }
                            
                        },
                        onFailure: nil)
                }
            })
        }
    }
    
    public func stopBackgroundUpdates()
    {
        if let ped = pedometer
        {
            ped.stopPedometerUpdates()
        }
    }
}
