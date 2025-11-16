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

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    private let TASK_ID = "com.bigbluefly.Duffy.get-steps"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LoggingService.log("App did finish launching")
        
        let session = WCSessionService.getInstance()
        session.activate(with: self)
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TASK_ID, using: nil) { task in
            self.handle(task: task as! BGAppRefreshTask)
        }
        
        TipService.getInstance().initialize()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        CoreMotionService.getInstance().stopBackgroundUpdates()
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
        
        if Globals.watchSystemVersion() < 6.0 {
            WCSessionService.getInstance().askForSystemVersion() { watchVersion in
                Globals.setWatchSystemVersion(watchVersion)
            }
        }
    }
    
    func sessionWasNotActivated() {
        HealthKitService.getInstance().initializeBackgroundQueries()
        CoreMotionService.getInstance().initializeBackgroundUpdates()
    }
    
    func systemVersion() -> Double {
        return Double(UIDevice.current.systemVersion) ?? 11.0
    }
}

//MARK: BGTask Handling

extension AppDelegate {

    func handle(task: BGAppRefreshTask) {
        LoggingService.log("Handle BG Task")
        
        scheduleTask()
        
        StepsProcessingService.triggerUpdate(from: "BGAppRefreshTask") {
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleTask() {
        let request = BGAppRefreshTaskRequest(identifier: TASK_ID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            LoggingService.log(error: error)
        }
    }

}
