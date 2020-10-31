//
//  StepsProcessingService.swift
//  Duffy
//
//  Created by Patrick Rills on 9/13/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public class StepsProcessingService {
    
    class func handleSteps(_ stepCount: Steps, for day: Date, from source: String) {
        if HealthCache.saveStepsToCache(stepCount, for: day) {
            LoggingService.log(String(format: "updateWatchFaceComplication from %@", source), with: String(format: "%d", stepCount))
            WCSessionService.getInstance().updateWatchFaceComplication(with: stepCount, for: day)
        }
        
        if stepCount >= HealthCache.dailyGoal(), day.isToday() {
            HealthCache.incrementGoalReachedCounter()
            NotificationService.sendDailyStepsGoalNotification()
        }
    }
    
    public class func triggerUpdate(from source: String, completion: @escaping () -> ()) {
        var isWatch = true
        #if os(iOS)
            isWatch = false
        #endif
        
        if CoreMotionService.getInstance().isEnabled() && isWatch {
            CoreMotionService.getInstance().updateStepsForToday(from: source, completion: { completion() })
        } else {
            HealthKitService.getInstance().getSteps(for: Date()) { result in
                switch result {
                case .success(_):
                    LoggingService.log(String(format: "Successfully refreshed HK steps on %@", source), at: .debug)
                case .failure(let error):
                    LoggingService.log(error: error)
                }
                
                completion()
            }
        }
    }
}
