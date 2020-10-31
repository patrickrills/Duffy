//
//  AppDelegate.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    private let TASK_ID = "com.bigbluefly.Duffy.get-steps"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LoggingService.log("App did finish launching")
        
        let session = WCSessionService.getInstance()
        session.activate(with: self)
        
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: TASK_ID, using: nil) { task in
                self.handle(task: task as! BGAppRefreshTask)
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
        LoggingService.log("App will resign active")
        
        if let w = window
        {
            if let root = w.rootViewController as? MainTableViewController
            {
                root.unsubscribeToHealthUpdates()
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LoggingService.log("App did enter background")
        scheduleTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        LoggingService.log("App will enter foreground")
        
        if let w = window
        {
            if let root = w.rootViewController as? MainTableViewController
            {
                root.refresh()
                root.subscribeToHealthUpdates()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        LoggingService.log("App did become active")
        
        //TODO: If session is not paired, try to here?
        //let session = WCSessionService.getInstance()
        //if !session.isPairingInValidState() {
        //    session.activate(with: self)
        //}
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        CoreMotionService.getInstance().stopBackgroundUpdates()
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        if let host = url.host, host == "debug" {
            DebugService.toggleDebugMode()
        }
        
        return true
    }
}

//MARK: WCSessionServiceDelegate Implements

extension AppDelegate: WCSessionServiceDelegate {
    
    func complicationUpdateRequested() {
        //do nothing
    }
    
    func sessionWasActivated() {
        HealthKitService.getInstance().initializeBackgroundQueries()
        CoreMotionService.getInstance().initializeBackgroundUpdates()
    }
    
    func sessionWasNotActivated() {
        HealthKitService.getInstance().initializeBackgroundQueries()
        CoreMotionService.getInstance().initializeBackgroundUpdates()
    }
}

//MARK: BGTask Handling

extension AppDelegate {

    @available(iOS 13.0, *)
    func handle(task: BGAppRefreshTask) {
        LoggingService.log("Handle BG Task")
        
        scheduleTask()
        
        StepsProcessingService.triggerUpdate(from: "BGAppRefreshTask") {
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleTask() {
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: TASK_ID)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
            
            do {
                try BGTaskScheduler.shared.submit(request)
                LoggingService.log("BG Task Scheduled", with: "\(request.earliestBeginDate ?? Date())")
            } catch {
                LoggingService.log(error: error)
            }
        }
    }

}
