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
    
    private func queryHealthKit(from source:String)
    {
        HealthKitService.getInstance().getSteps(Date(),
        onRetrieve: {
            (steps: Int, forDay: Date) in
            
            LoggingService.log(String(format: "Steps retrieved from HK by %@", source), with: String(format: "%d", steps))
            
            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
            {
                LoggingService.log("updateWatchFaceComplication from %@", with: String(format: "%d", steps))
                WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
            }
            else
            {
                LoggingService.log(String(format: "Steps not saved to cache from HK by %@", source), with: String(format: "%d", steps))
            }
        },
        onFailure: nil)
    }
}
