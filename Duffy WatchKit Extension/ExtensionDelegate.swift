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

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionServiceDelegate
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
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    /*
    func applicationDidEnterBackground() 
     {
        scheduleNextBackgroundRefresh()
    }
    */

    func complicationUpdateRequested(_ complicationData : [String : AnyObject])
    {
        ComplicationController.refreshComplication()
        scheduleSnapshotNow()
    }
    
    @available(watchOSApplicationExtension 3.0, *)
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
                        //NSLog(String(format: "snapshot root: %@", c.description))
                        //os_log("snapshot root: %@", c.description)
                        c.displayTodaysStepsFromHealth()
                    }
                    
                    currentBackgroundTasks.removeValue(forKey: dictKey)
                    (t as! WKSnapshotRefreshBackgroundTask).setTaskCompleted(restoredDefaultState: false, estimatedSnapshotExpiration: Date.init(timeIntervalSinceNow: 60*30), userInfo: nil)
                }
                else
                {
                    //NSLog(String(format: "task class: %@", t.description))
                    //os_log("task class: %@", t.description)
                    
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
                                //os_log("Update complication from bg task with %d steps", steps)
                                ComplicationController.refreshComplication()
                            }
                        
                            self?.scheduleNextBackgroundRefresh()
                            let _ = self?.currentBackgroundTasks.removeValue(forKey: dictKey)
                            t.setTaskCompleted()
                        },
                        onFailure: {
                            [weak self] (error: Error?) in
                            
                            /*
                            if let e = error {
                                os_log("Error getting steps in bg task: %@", e.localizedDescription)
                            } else {
                                os_log("Error getting steps in bg task with unknown error")
                            }
                            */
                            
                            self?.scheduleNextBackgroundRefresh()
                            let _ = self?.currentBackgroundTasks.removeValue(forKey: dictKey)
                            t.setTaskCompleted()
                    })
                }
            }
        }
    }
    
    func scheduleNextBackgroundRefresh()
    {
        let userInfo = ["reason" : "background update"] as NSDictionary
        let refreshDate = Date(timeIntervalSinceNow: 60*30)
        
        if #available(watchOSApplicationExtension 3.0, *) {
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: userInfo, scheduledCompletion: {
                (err: Error?) in
                
                /*
                if err != nil {
                    os_log("error requesting bg refresh")
                } else {
                    os_log("background refresh requested")
                }
                */
                
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func scheduleSnapshotNow()
    {
        if #available(watchOSApplicationExtension 3.0, *) {
            WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(), userInfo: nil, scheduledCompletion: {
                (err: Error?) in
                
                /*
                if err != nil {
                    os_log("error requesting snapshot refresh")
                } else {
                    os_log("snapshot refresh requested")
                }
                */
            })
        }
    }
}
