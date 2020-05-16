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
        guard !shouldAskPermission(), let ped = pedometer else { return }
        
        if CMPedometer.isPedometerEventTrackingAvailable() {
            ped.startEventUpdates(handler: {
                [weak self] event, error in
                if let type = event?.type {
                    let source = (type == .resume ? "CMPedometer resume" : "CMPedometer pause")
                    #if os(iOS)
                        self?.queryHealthKit(from: source)
                    #else
                        self?.queryCoreMotion(from: source, completion: nil)
                    #endif
                }
            })
        }
        
        #if os(watchOS)
            ped.startUpdates(from: Date(), withHandler: {
                [weak self] data, error in
                self?.queryCoreMotion(from: "CMPedometer updates", completion: nil)
                
            })
        #endif
    }
    
    open func stopBackgroundUpdates()
    {
        guard !shouldAskPermission(), let ped = pedometer else { return }
        
        if CMPedometer.isPedometerEventTrackingAvailable() {
            ped.stopEventUpdates()
        }
    }
    
    open func shouldAskPermission() -> Bool
    {
        return CMPedometer.isStepCountingAvailable() && CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.authorizationStatus() == .notDetermined
    }
    
    open func askForPermission()
    {
        if shouldAskPermission() {
            if let ped = pedometer {
                ped.queryPedometerData(from: Date(), to: Date(), withHandler: {
                    [weak self] steps, error in
                    self?.initializeBackgroundUpdates()
                })
            }
        }
    }
    
    open func isEnabled() -> Bool {
        return pedometer != nil && !shouldAskPermission()
    }
    
    open func updateStepsForToday(from source: String, completion: @escaping ()->())
    {
        guard isEnabled() else {
            completion()
            return
        }
        
        queryCoreMotion(from: source, completion: completion)
    }
    
    private func queryCoreMotion(from source: String, completion: (()->())?)
    {
        if let pedometer = pedometer {
            let now = Date()
            var components = Calendar.current.dateComponents([.era, .year, .month, .day], from: now)
            components.hour = 0
            components.minute = 0
            components.second = 1
            components.timeZone = TimeZone.current
            if let todayAtMidnight = Calendar.current.date(from: components) {
                pedometer.queryPedometerData(from: todayAtMidnight, to: now, withHandler: {
                    [weak self] data, error in
                    if let stepData = data {
                        let cmSteps = stepData.numberOfSteps.intValue
                        let cmStartDate = stepData.endDate
                        LoggingService.log(String(format: "CMPedometer steps from %@", source), with: String(format: "%d", cmSteps))
                        if (HealthCache.saveStepsToCache(cmSteps, forDay: cmStartDate)) {
                            self?.forceComplicationUpdate(from: String(format: "CMPedometer steps from %@", source))
                        }
                    }
                    
                    if let completion = completion {
                        completion()
                    }
                })
                return
            }
        }
        
        if let completion = completion {
            completion()
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
        onFailure: {
            error in
            if let error = error {
                LoggingService.log(error: error)
            }
        })
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
