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
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate
{
    var currentBackgroundTasks: [String : AnyObject] = [:]
        
    override init()
    {
        super.init()
        WCSessionService.getInstance().activate(with: self)
    }
    
    func applicationDidFinishLaunching() {
        LoggingService.log("App did finish launching")
        startHealthKitBackgroundQueries()
        NotificationService.maybeAskForNotificationPermission(self)
        if CoreMotionService.getInstance().shouldAskPermission() {
            CoreMotionService.getInstance().askForPermission()
        } else {
            CoreMotionService.getInstance().initializeBackgroundUpdates()
        }
        
        if (HealthCache.cacheIsForADifferentDay(than: Date())) {
            complicationUpdateRequested()
        }
    }
    
    func applicationWillEnterForeground() {
        LoggingService.log("App will enter foreground")
        
        if let c = WKExtension.shared().rootInterfaceController as? MainInterfaceController {
            if WKExtension.shared().isApplicationRunningInDock {
                c.refresh()
            }
            
            c.subscribeToHealthKitUpdates()
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
    
    func applicationDidEnterBackground() {
        LoggingService.log("App will enter background")
        
        if let c = WKExtension.shared().rootInterfaceController as? MainInterfaceController {
            c.unsubscribeToHealthKitUpdates()
        }
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
                    
                    if let c = WKExtension.shared().rootInterfaceController as? MainInterfaceController {
                        c.updateInterfaceFromSnapshot()
                    }
                    
                    complete(task: t)
                }
                else
                {
                    LoggingService.log("Background update task handled")
                    
                    StepsProcessingService.triggerUpdate(from: "WKRefreshBackgroundTask") { [weak self] in
                        self?.complete(task: t)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    private func startHealthKitBackgroundQueries() {
        HealthKitService.getInstance().initializeBackgroundQueries()
    }
}

extension ExtensionDelegate: WCSessionServiceDelegate {
    
    func complicationUpdateRequested() {
        ComplicationController.refreshComplication()
        scheduleSnapshotNow()
    }
    
    func sessionWasActivated() {
        //Do nothing
    }
    
    func sessionWasNotActivated() {
        //Do nothing
    }
    
    func systemVersion() -> Double {
        return Double(WKInterfaceDevice.current().systemVersion) ?? 4.0
    }
    
}
