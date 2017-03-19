//
//  NotificationService.swift
//  Duffy
//
//  Created by Patrick Rills on 3/19/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import Foundation
import UserNotifications

open class NotificationService
{
    open class func sendDailyStepsGoalNotification()
    {
        guard #available(iOS 10.0, watchOSApplicationExtension 3.0, *) else {
            return
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 1
        
        let content = UNMutableNotificationContent()
        content.title = "Way to go!"
        content.body = String(format: "You've reached your goal of %@ steps.", numberFormatter.string(from: NSNumber(value: HealthCache.getStepsDailyGoal()))!)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(Constants.notificationDelayInSeconds), repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "DailyStepsGoal", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        NSLog("Notification queued")
    }
    
    open class func maybeAskForNotificationPermission()
    {
        guard #available(iOS 10.0, watchOSApplicationExtension 3.0, *) else {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                NSLog("Notification permission granted")
            } else {
                NSLog("Notification permission DENIED")
            }
        }
    }
}
