//
//  NotificationService.swift
//  Duffy
//
//  Created by Patrick Rills on 3/19/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import Foundation
import UserNotifications

public class NotificationService
{
    public class func sendDailyStepsGoalNotification() {
        #if os(iOS)
            WCSessionService.getInstance().triggerGoalNotificationOnWatch(day: Date())
            LoggingService.log("Send goal trigger to watch")
        #else
            if (dailyStepsGoalNotificationWasAlreadySent()) {
                return
            }
        
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = 1
        
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("Way to go!", comment: "")
            content.body = String(format: NSLocalizedString("You've reached your goal of %@ steps.", comment: ""), numberFormatter.string(for: HealthCache.dailyGoal())!)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "goal-notification"
        
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(Constants.notificationDelayInSeconds), repeats: false)
        
            let request = UNNotificationRequest(identifier: String(format: "DailyStepsGoal-%@", convertDayToKey(Date())), content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
            setDailyStepsGoalNotificationSent()
        #endif
    }
    
    public class func maybeAskForNotificationPermission(_ delegate : UNUserNotificationCenterDelegate?) {
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private static let CACHE_KEY = "lastGoalNotificationSent"
    
    public class func dailyStepsGoalNotificationWasAlreadySent() -> Bool {
        if let lastSent = UserDefaults.standard.object(forKey: CACHE_KEY) as? String,
           lastSent == convertDayToKey(Date())
        {
            return true
        }
        
        return false
    }
    
    private class func setDailyStepsGoalNotificationSent() {
        cacheLastDaySent()
        WCSessionService.getInstance().notifyOtherDeviceOfGoalNotificaton()
    }
    
    private class func cacheLastDaySent() {
        UserDefaults.standard.set(convertDayToKey(Date()), forKey: CACHE_KEY)
        UserDefaults.standard.synchronize()
    }
    
    public class func convertDayToKey(_ day: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd"
        return dateFormatter.string(from: day)
    }
    
    public class func markNotificationSentByOtherDevice(for key: String) {
        if key == convertDayToKey(Date()) {
            cacheLastDaySent()
        }
    }
}
