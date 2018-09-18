//
//  ExtensionDelegate.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import DuffyWatchFramework
import os.log
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
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
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
                    if let c = WKExtension.shared().rootInterfaceController as? InterfaceController
                    {
                        c.displayTodaysStepsFromCache()
                    }
                    
                    complete(task: t)
                }
                else
                {
                    //At least turn over the complication to zero if it is a new day - if the lock is locked we can't get the steps
                    if (HealthCache.cacheIsForADifferentDay(Date()))
                    {
                        if (HealthCache.saveStepsToCache(0, forDay: Date())) {
                            ComplicationController.refreshComplication()
                        }
                    }
                    
                    HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
                            [weak self] (steps: Int, forDay: Date) in
                        
                            self?.scheduleSnapshotNow()
                        
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
        
        if #available(watchOSApplicationExtension 4.0, *)
        {
            task.setTaskCompletedWithSnapshot(true)
        }
        else
        {
            if task is WKSnapshotRefreshBackgroundTask
            {
                (task as! WKSnapshotRefreshBackgroundTask).setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.init(timeIntervalSinceNow: 60*30), userInfo: nil)
            }
            else
            {
                task.setTaskCompleted()
            }
        }
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
