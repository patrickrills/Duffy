//
//  CoreMotionService.swift
//  Duffy
//
//  Created by Patrick Rills on 7/24/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import CoreMotion

open class CoreMotionService
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
    
    open class func getInstance() -> CoreMotionService
    {
        return instance
    }
    
    open func initializeBackgroundUpdates()
    {
        if let ped = pedometer
        {
            ped.startUpdates(from: Date(), withHandler: {
                [weak self] data, error in
                if let stepData = data {
                    LoggingService.log("CMPedometer update triggered", with: String(format: "%@", stepData.numberOfSteps))
                    self?.queryHealthKit(from: "CM Update")
                }
            })
            
            if CMPedometer.isPedometerEventTrackingAvailable() {
                ped.startEventUpdates(handler: {
                    [weak self] event, error in
                    if let type = event?.type {
                        LoggingService.log((type == .resume ? "CMPedometer resume event" : "CMPedometer pause event"))
                        #if os(iOS)
                            self?.forceComplicationUpdate(from: "CM Event before HK query")
                        #endif
                        self?.queryHealthKit(from: "CM Event")
                    }
                })
            }
        }
    }
    
    open func stopBackgroundUpdates()
    {
        if let ped = pedometer
        {
            ped.stopUpdates()
            
            if CMPedometer.isPedometerEventTrackingAvailable() {
                ped.stopEventUpdates()
            }
        }
    }
    
    private func queryHealthKit(from source: String)
    {
        HealthKitService.getInstance().getSteps(Date(),
        onRetrieve: {
            [weak self] (steps: Int, forDay: Date) in
            
            LoggingService.log(String(format: "Steps retrieved from HK by %@", source), with: String(format: "%d", steps))
            
            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
            {
                self?.forceComplicationUpdate(from: source)
            }
            else
            {
                LoggingService.log(String(format: "Steps not saved to cache from HK by %@", source), with: String(format: "%d", steps))
            }
        },
        onFailure: nil)
    }
    
    private func forceComplicationUpdate(from source: String)
    {
        let cache = HealthCache.getStepsDataFromCache()
        var logSteps = "?"
        if let steps = cache["stepsCacheValue"] as? Int {
            logSteps = String(format: "%d", steps)
        }
        LoggingService.log(String(format: "updateWatchFaceComplication from %@", source), with: logSteps)
        WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : cache as AnyObject])
    }
}
