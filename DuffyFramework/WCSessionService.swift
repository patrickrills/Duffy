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

public class WCSessionService : NSObject
{
    //MARK: instance properties
    
    private static let instance: WCSessionService = WCSessionService()
    private weak var delegate: WCSessionServiceDelegate?
    
    //MARK: Constructors and initialization
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            WCSession.default.delegate = self
        }
    }
    
    public class func getInstance() -> WCSessionService {
        return instance
    }
    
    public func activate(with delegate: WCSessionServiceDelegate) {
        self.delegate = delegate
        if (WCSession.isSupported()) {
            WCSession.default.activate()
        } else {
            delegate.sessionWasNotActivated?()
        }
    }
   
    //MARK: Transfer functions
    
    public func updateWatchFaceComplication(with steps: Steps) {
        let complicationData = ["stepsdataresponse" : steps as AnyObject]
        
        #if os(iOS)
            sendComplicationDataToWatch(complicationData)
        #else
            if let delegate = delegate {
                delegate.complicationUpdateRequested(complicationData)
            }
        #endif
    }
    
    private func sendComplicationDataToWatch(_ complicationData : [String : AnyObject]) {
        #if os(iOS)
            guard WCSession.isSupported(),
                  WCSession.default.activationState == .activated
            else {
                LoggingService.log("WCSession NOT activated", at: .debug)
                return
            }
        
            if WCSession.default.isComplicationEnabled {
                WCSession.default.transferCurrentComplicationUserInfo(complicationData)
                LoggingService.log("Requested to send data to watch, remaining transfers", with: transfersRemaining().description)
            } else {
                LoggingService.log("Complication NOT enabled", at: .debug)
            }
        #endif
    }
    
    public func notifyOtherDeviceOfGoalNotificaton() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated
        else {
            return
        }
        
        WCSession.default.sendMessage(["goalNotificationSent" : NotificationService.convertDayToKey(Date()) as AnyObject], replyHandler: nil, errorHandler: nil)
    }
    
    public func sendStepsGoal(goal: Steps) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated
        else {
            return
        }
        
        WCSession.default.sendMessage(["stepsGoal" : goal], replyHandler: nil, errorHandler: { (err: Error?) in
            if let e = err {
                LoggingService.log(error: e)
            }
        })
    }
    
    public func sendDebugLog(_ log: [DebugLogEntry], onCompletion: @escaping (Bool) -> ()) {
        let serializedLog = log.map({ $0.serialize() })
        send(message: "watchDebugLog", payload: serializedLog, onCompletion: { success in
            onCompletion(success)
        })
    }
    
    public func toggleDebugMode(_ isOn: Bool) {
        send(message: "debugMode", payload: (isOn ? 1 : 0), onCompletion: { _ in })
    }
    
    private func send(message name: String, payload: Any, onCompletion: @escaping (Bool) -> ()) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated
        else {
            return
        }
        
        WCSession.default.sendMessage([name : payload],
                                      replyHandler: { _ in
                                        onCompletion(true)
                                      },
                                      errorHandler: { err in
                                        LoggingService.log(error: err)
                                        onCompletion(false)
        })
    }
    
    //MARK: Message parsing
    
    private func handle(message: [String : Any]) {
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
                            LoggingService.log("Refreshing complication from received message", with: String(format: "%d", HealthCache.lastSteps(for: Date())))
                            del.complicationUpdateRequested(dict)
                        }
                        
                        if HealthCache.lastSteps(for: Date()) >= HealthCache.dailyGoal()
                        {
                            NotificationService.sendDailyStepsGoalNotification()
                        }
                    }
                }
            }
            else if (key == "stepsGoal")
            {
                if let goalVal = value as? Steps
                {
                    HealthCache.saveDailyGoal(goalVal)
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
    
    private func updateSteps() {
        if CoreMotionService.getInstance().isEnabled() {
            CoreMotionService.getInstance().updateStepsForToday(from: "didReceiveUserInfo", completion: { LoggingService.log("Successfully refreshed steps on didReceiveUserInfo", at: .debug) })
        } else {
            HealthKitService.getInstance().getSteps(for: Date()) { result in
                switch result {
                case .success(_):
                    LoggingService.log("Successfully refreshed HK steps on didReceiveUserInfo", at: .debug)
                case .failure(let error):
                    LoggingService.log(error: error)
                }
            }
        }
    }
    
    //MARK: Diagnostics
    
    public func transfersRemaining() -> Int {
        #if os(iOS)
            if (WCSession.isSupported()) {
                return WCSession.default.remainingComplicationUserInfoTransfers
            }
        #endif
        
        return 0
    }
}


extension WCSessionService: WCSessionDelegate {
    
    //MARK: WCSessionDelegate conformance
    
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
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handle(message: message)
        replyHandler(["received" : Int(1)])
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message: message)
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        LoggingService.log("Message received didReceiveUserInfo")
        #if os(watchOS)
            updateSteps()
        #endif
        handle(message: userInfo)
    }

    public func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
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
    
    #if os(iOS)
        public func sessionDidDeactivate(_ session: WCSession) {
            //Do nothing - protocol conformance
        }
        
        public func sessionDidBecomeInactive(_ session: WCSession) {
            //Do nothing - protocol conformance
        }
    #endif
}
