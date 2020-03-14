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
                    self?.queryHealthKit()
                }
            })
            
            if CMPedometer.isPedometerEventTrackingAvailable() {
                ped.startEventUpdates(handler: {
                    [weak self] event, error in
                    if let type = event?.type {
                        LoggingService.log((type == .resume ? "CMPedometer resume event" : "CMPedometer pause event"))
                        self?.queryHealthKit()
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
    
    private func queryHealthKit()
    {
        HealthKitService.getInstance().getSteps(Date(),
        onRetrieve: {
            (steps: Int, forDay: Date) in
            
            LoggingService.log("Steps retrieved from HK by core motion", with: String(format: "%d", steps))
            
            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
            {
                LoggingService.log("updateWatchFaceComplication from core motion", with: String(format: "%d", steps))
                WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
            }
            
        },
        onFailure: nil)
    }
}
