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
        WCSessionService.getInstance().activate(with: self)
    }
    
    func applicationDidFinishLaunching() {
        LoggingService.log("App did finish launching")
        // Perform any final initialization of your application.
        HealthKitService.getInstance().initializeBackgroundQueries()
        HealthKitService.getInstance().setEventDelegate(self)
        NotificationService.maybeAskForNotificationPermission(self)
        if CoreMotionService.getInstance().shouldAskPermission() {
            CoreMotionService.getInstance().askForPermission()
        } else {
            CoreMotionService.getInstance().initializeBackgroundUpdates()
        }
        
        if (HealthCache.cacheIsForADifferentDay(Date())) {
            complicationUpdateRequested([:])
        }
    }
    
    func applicationWillEnterForeground() {
        LoggingService.log("App will enter foreground")
        if WKExtension.shared().isApplicationRunningInDock,
            let c = WKExtension.shared().rootInterfaceController as? InterfaceController {
            c.refreshPressed()
        }
    }
    
    func applicationDidBecomeActive() {
        LoggingService.log("App did become active")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        LoggingService.log("App will resign active")
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
                        c.updateInterfaceFromSnapshot()
                    }
                    
                    complete(task: t)
                }
                else
                {
                    LoggingService.log("Background update task handled")
                    
                    //Try to update steps from CoreMotion first unless its not enabled
                    if CoreMotionService.getInstance().isEnabled() {
                        CoreMotionService.getInstance().updateStepsForToday(from: "WKRefreshBackgroundTask", completion: {
                            [weak self] in
                            self?.complete(task: t)
                        })
                    } else {
                        //Fallback to using Healthkit if core motion not enabled
                        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
                            [weak self] (steps: Int, forDay: Date) in
                                                                    
                            if (HealthCache.saveStepsToCache(steps, forDay: forDay)) {
                                LoggingService.log("Refresh complication in background task")
                                ComplicationController.refreshComplication()
                            }
                                            
                            self?.complete(task: t)
                        },
                        onFailure: {
                            [weak self] (error: Error?) in
                            LoggingService.log("Error getting steps in background task")
                            self?.complete(task: t)
                        })
                    }
                }
            }
        }
    }
    
    func complete(task: WKRefreshBackgroundTask)
    {
        let dictKey = String(describing: type(of: task))
        currentBackgroundTasks.removeValue(forKey: dictKey)
        if let snapshot = task as? WKSnapshotRefreshBackgroundTask {
            snapshot.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date(timeIntervalSinceNow: 60*30), userInfo: nil)
        } else {
            task.setTaskCompletedWithSnapshot(true)
        }
    }
    
    func scheduleNextBackgroundRefresh()
    {
        let userInfo = ["reason" : "background update"] as NSDictionary
        let refreshDate = Date(timeIntervalSinceNow: 60*30)
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: userInfo, scheduledCompletion: {
            (err: Error?) in
            if let e = err {
                LoggingService.log(error: e)
            }
        })
    }
    
    func scheduleSnapshotNow()
    {
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(), userInfo: nil, scheduledCompletion: {
            (err: Error?) in
            if let e = err {
                LoggingService.log(error: e)
            }
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
