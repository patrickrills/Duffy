//
//  ExtensionDelegate.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import DuffyWatchFramework
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionServiceDelegate, HealthEventDelegate, UNUserNotificationCenterDelegate
{
    var currentBackgroundTasks: [String : AnyObject] = [:]
    
    override init()
    {
        super.init()
        WCSessionService.getInstance().initialize(self)
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        HealthKitService.getInstance().initializeBackgroundQueries()
        HealthKitService.getInstance().setEventDelegate(self)
        NotificationService.maybeAskForNotificationPermission(self)
        
        if (HealthCache.cacheIsForADifferentDay(Date())) {
            complicationUpdateRequested([:])
            if Constants.isDebugMode {
                LoggingService.log("roll over complication in applicationDidFinishLaunching")
            }
        }
    }
    
    func applicationWillEnterForeground() {
        if WKExtension.shared().isApplicationRunningInDock,
            let c = WKExtension.shared().rootInterfaceController as? InterfaceController {
            c.refreshPressed()
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func complicationUpdateRequested(_ complicationData : [String : AnyObject])
    {
        ComplicationController.refreshComplication()
        scheduleSnapshotNow()
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>)
    {
        for t in backgroundTasks
        {
            if WKExtension.shared().applicationState == .background
            {
                let dictKey = String(describing: type(of: t))
                currentBackgroundTasks[dictKey] = t
                
                if t is WKSnapshotRefreshBackgroundTask
                {
                    LoggingService.log("Snapshot task handled")
                    
                    if let c = WKExtension.shared().rootInterfaceController as? InterfaceController
                    {
                        c.displayTodaysStepsFromCache()
                    }
                    
                    if HealthCache.getStepsFromCache(Date()) == 0 {
                        ComplicationController.refreshComplication()
                    }
                    
                    complete(task: t)
                }
                else
                {
                    LoggingService.log("Background update task handled")
                    
                    //At least turn over the complication to zero if it is a new day - if the screen is locked we can't get the steps
                    if (HealthCache.cacheIsForADifferentDay(Date()))
                    {
                        if (HealthCache.saveStepsToCache(0, forDay: Date())) {
                            ComplicationController.refreshComplication()
                        }
                    }
                    
                    HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
                            [weak self] (steps: Int, forDay: Date) in
                        
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay))
                            {
                                ComplicationController.refreshComplication()
                            }
                        
                            self?.complete(task: t)
                        },
                        onFailure: {
                            [weak self] (error: Error?) in
    
                            self?.complete(task: t)
                    })
                }
            }
        }
    }
    
    func complete(task: WKRefreshBackgroundTask)
    {
        let dictKey = String(describing: type(of: task))
        currentBackgroundTasks.removeValue(forKey: dictKey)
        task.setTaskCompletedWithSnapshot(true)
    }
    
    func scheduleNextBackgroundRefresh()
    {
        let userInfo = ["reason" : "background update"] as NSDictionary
        let refreshDate = Date(timeIntervalSinceNow: 60*30)
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: userInfo, scheduledCompletion: {
            (err: Error?) in
        })
    }
    
    func scheduleSnapshotNow()
    {
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(), userInfo: nil, scheduledCompletion: {
            (err: Error?) in
        })
    }
    
    func dailyStepsGoalWasReached()
    {
        NotificationService.sendDailyStepsGoalNotification()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler(UNNotificationPresentationOptions.alert)
    }
}
