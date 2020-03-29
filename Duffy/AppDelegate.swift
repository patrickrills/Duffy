//
//  AppDelegate.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionServiceDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LoggingService.log("App did finish launching")
        let session = WCSessionService.getInstance()
        session.activate(with: self)
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
        
        //Synchronize daily goal to shared defaults if its never been done so Today extension can know the goal
        if HealthCache.getStepsDailyGoal() > 0,
            HealthCache.getStepsDailyGoal() != HealthCache.getStepsDailyGoalFromShared() {
            HealthCache.saveStepsGoalToCache(HealthCache.getStepsDailyGoal())
        }
        
        //TODO: If session is not paired, try to here?
        //let session = WCSessionService.getInstance()
        //if !session.isPairingInValidState() {
        //    session.activate(with: self)
        //}
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        if let host = url.host, host == "debug" {
            DebugService.toggleDebugMode()
        }
        
        return true
    }
    
    func complicationUpdateRequested(_ complicationData: [String : AnyObject]) {
        //do nothing
    }
    
    func sessionWasActivated() {
        LoggingService.log("App received session activate message - start observers")
        HealthKitService.getInstance().initializeBackgroundQueries()
    }
    
    func sessionWasNotActivated() {
        LoggingService.log("App received session NOT activated message - start observers")
        HealthKitService.getInstance().initializeBackgroundQueries()
    }
}

