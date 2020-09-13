//
//  WCSessionService.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import WatchConnectivity

@objc public protocol WCSessionServiceDelegate
{
    func complicationUpdateRequested(_ complicationData : [String : AnyObject])
    @objc optional func sessionWasActivated()
    @objc optional func sessionWasNotActivated()
}

open class WCSessionService : NSObject, WCSessionDelegate
{
    #if os(iOS)
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
   }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    #endif
   
   /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            delegate?.sessionWasActivated?()
        } else {
            if let e = error {
                LoggingService.log(error: e)
            }
            delegate?.sessionWasNotActivated?()
        }
    }
    
    fileprivate static let instance: WCSessionService = WCSessionService()
    fileprivate var delegate: WCSessionServiceDelegate?
    
    override init()
    {
        super.init()
        
        if (WCSession.isSupported())
        {
            WCSession.default.delegate = self
        }
    }
    
    open class func getInstance() -> WCSessionService
    {
        return instance
    }
    
    open func activate(with delegate: WCSessionServiceDelegate)
    {
        self.delegate = delegate
        if (WCSession.isSupported()) {
            WCSession.default.activate()
        } else {
            delegate.sessionWasNotActivated?()
        }
    }
    
    open func transfersRemaining() -> Int {
        #if os(iOS)
            if (WCSession.isSupported()) {
                return WCSession.default.remainingComplicationUserInfoTransfers
            }
        #endif
        
        return 0
    }
    
    open func updateWatchFaceComplication(_ complicationData : [String : AnyObject])
    {
        #if os(iOS)
            sendComplicationDataToWatch(complicationData)
        #else
            if let del = delegate
            {
                del.complicationUpdateRequested(complicationData)
            }
        #endif
    }
    
    fileprivate func sendComplicationDataToWatch(_ complicationData : [String : AnyObject])
    {
        #if os(iOS)
            if (WCSession.isSupported())
            {
                if WCSession.default.activationState == .activated
                {
                    if WCSession.default.isComplicationEnabled {
                        WCSession.default.transferCurrentComplicationUserInfo(complicationData)
                        let remaining = WCSession.default.remainingComplicationUserInfoTransfers
                        LoggingService.log("Requested to send data to watch, remaining transfers", with: remaining.description)
                    } else {
                        LoggingService.log("Complication NOT enabled", at: .debug)
                    }
                }
                else
                {
                    LoggingService.log("WCSession NOT activated", at: .debug)
                }
            }
        #endif
    }
    
    open func notifyOtherDeviceOfGoalNotificaton()
    {
        if WCSession.isSupported()
        {
            if WCSession.default.activationState == .activated
            {
                WCSession.default.sendMessage(["goalNotificationSent" : NotificationService.convertDayToKey(Date()) as AnyObject], replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    open func sendStepsGoal(goal: Int)
    {
        if WCSession.isSupported()
        {
            if WCSession.default.activationState == .activated
            {
                WCSession.default.sendMessage(["stepsGoal" : goal], replyHandler: nil, errorHandler: {
                    (err: Error?) in
                    if let e = err
                    {
                        print("send error:" + e.localizedDescription)
                    }
                })
            }
        }
    }
    
    open func sendDebugLog(_ log: [DebugLogEntry], onCompletion: @escaping (Bool)->(Void)) {
        let serializedLog = log.map({ $0.serialize() })
        WCSessionService.getInstance().send(message: "watchDebugLog", payload: serializedLog, onCompletion: {
            (success) in
            onCompletion(success)
        })
    }
    
    open func send(message name: String, payload: Any, onCompletion: @escaping (Bool) -> (Void)) {
        if WCSession.isSupported()
        {
            if WCSession.default.activationState == .activated
            {
                WCSession.default.sendMessage([name : payload],
                                              replyHandler: { (_) in
                                                onCompletion(true)
                                              },
                                              errorHandler: { (err: Error?) in
                                                if let e = err {
                                                    LoggingService.log(error: e)
                                                }
                                                onCompletion(false)
                })
            }
        }
    }
    
    open func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handle(message: message)
        replyHandler(["received" : Int(1)])
    }
    
    open func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    {
        handle(message: message)
    }
    
    open func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any])
    {
        LoggingService.log("Message received didReceiveUserInfo")
        #if os(watchOS)
            updateSteps()
        #endif
        handle(message: userInfo)
    }

    open func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        var dataTransferred = "?"
        
        #if os(iOS)
            if userInfoTransfer.isCurrentComplicationInfo,
                let stepsDict = userInfoTransfer.userInfo["stepsdataresponse"] as? [String : Any],
                let steps = stepsDict["stepsCacheValue"] as? Int {
                
                dataTransferred = "\(steps)"
            }
        #endif
        
        if let error = error {
            LoggingService.log("WCSession transfer userInfo FAILED", with: error.localizedDescription)
        } else {
            LoggingService.log("WCSession transferred userInfo", with: dataTransferred)
        }
    }
    
    fileprivate func handle(message: [String : Any]) {
        for (key, value) in message
        {
            if (key == "stepsdataresponse")
            {
                if let dict = value as? [String: AnyObject]
                {
                    if (HealthCache.saveStepsDataToCache(dict))
                    {
                        if let del = delegate
                        {
                            LoggingService.log("Refreshing complication from received message", with: String(format: "%d", HealthCache.getStepsFromCache(Date())))
                            del.complicationUpdateRequested(dict)
                        }
                        
                        if HealthCache.getStepsFromCache(Date()) >= HealthCache.getStepsDailyGoal()
                        {
                            NotificationService.sendDailyStepsGoalNotification()
                        }
                    }
                }
            }
            else if (key == "stepsGoal")
            {
                if let goalVal = value as? Int
                {
                    HealthCache.saveStepsGoalToCache(goalVal)
                }
            }
            else if (key == "goalNotificationSent")
            {
                if let dayKey = value as? String
                {
                    NotificationService.markNotificationSentByOtherDevice(forKey: dayKey)
                }
            }
            else if (key == "watchDebugLog")
            {
                if let log = value as? [[String : Any]] {
                    LoggingService.mergeLog(newEntries: log.map({ DebugLogEntry(deseralized: $0) }))
                }
            }
            else if (key == "debugMode")
            {
                DebugService.toggleDebugMode()
            }
        }
    }
    
    fileprivate func updateSteps() {
        if CoreMotionService.getInstance().isEnabled() {
            CoreMotionService.getInstance().updateStepsForToday(from: "didReceiveUserInfo", completion: { LoggingService.log("Successfully refreshed steps on didReceiveUserInfo", at: .debug) })
        } else {
            HealthKitService.getInstance().getSteps(for: Date()) { result in
                switch result {
                case .success(let stepsResult):
                    if (HealthCache.saveStepsToCache(Int(stepsResult.steps), forDay: stepsResult.day)) {
                        WCSessionService.getInstance().updateWatchFaceComplication(["stepsdataresponse" : HealthCache.getStepsDataFromCache() as AnyObject])
                    }
                case .failure(let error):
                    LoggingService.log(error: error)
                }
            }
        }
    }
}
