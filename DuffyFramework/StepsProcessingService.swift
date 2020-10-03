//
//  StepsProcessingService.swift
//  Duffy
//
//  Created by Patrick Rills on 9/13/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

internal class StepsProcessingService {
    
    class func handleSteps(_ stepCount: Steps, for day: Date, from source: String) {
        if HealthCache.saveStepsToCache(stepCount, for: day) {
            LoggingService.log(String(format: "updateWatchFaceComplication from %@", source), with: String(format: "%d", stepCount))
            WCSessionService.getInstance().updateWatchFaceComplication(with: stepCount)
        }
        
        if stepCount >= HealthCache.dailyGoal(), day.isToday() {
            HealthCache.incrementGoalReachedCounter()
            NotificationService.sendDailyStepsGoalNotification()
        }
    }
    
}
