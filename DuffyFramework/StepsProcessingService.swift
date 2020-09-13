//
//  StepsProcessingService.swift
//  Duffy
//
//  Created by Patrick Rills on 9/13/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

internal class StepsProcessingService {
    
    class func handleSteps(_ stepCount: Steps, for day: Date, from source: String, handler: HealthEventDelegate?) {
        if HealthCache.saveStepsToCache(Int(stepCount), forDay: day) {
            LoggingService.log(String(format: "updateWatchFaceComplication from %@", source), with: String(format: "%d", stepCount))
            WCSessionService.getInstance().updateWatchFaceComplication(with: stepCount)
        }
        
        if stepCount >= HealthCache.getStepsDailyGoal(), day.isToday() {
            HealthCache.incrementGoalReachedCounter()
        
            if let handler = handler {
                handler.dailyStepsGoalWasReached()
            }
        }
    }
    
}
