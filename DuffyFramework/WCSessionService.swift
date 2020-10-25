//
//  WCSessionService.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import WatchConnectivity

public protocol WCSessionServiceDelegate: class
{
    func complicationUpdateRequested()
    func sessionWasActivated()
    func sessionWasNotActivated()
}

public class WCSessionService : NSObject
{
    //MARK: instance properties
    
    private static let instance: WCSessionService = WCSessionService()
    private weak var delegate: WCSessionServiceDelegate?
    
    //MARK: Constructors and initialization
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
        }
    }
    
    public class func getInstance() -> WCSessionService {
        return instance
    }
    
    public func activate(with delegate: WCSessionServiceDelegate) {
        self.delegate = delegate
        if WCSession.isSupported() {
            WCSession.default.activate()
        } else {
            delegate.sessionWasNotActivated()
        }
    }
   
    //MARK: Transfer functions
    
    public func updateWatchFaceComplication(with steps: Steps, for day: Date) {
        #if os(iOS)
            sendComplicationDataToWatch(steps, day: day)
        #else
            delegate?.complicationUpdateRequested()
        #endif
    }
    
    private func sendComplicationDataToWatch(_ steps: Steps, day: Date) {
        #if os(iOS)
            guard WCSession.isSupported(),
                  WCSession.default.activationState == .activated
            else {
                LoggingService.log("WCSession NOT activated", at: .debug)
                return
            }
        
            if WCSession.default.isComplicationEnabled {
                let complicationData = WCSessionMessage.complicationUpdate(steps: steps, day: day)
                WCSession.default.transferCurrentComplicationUserInfo(complicationData.message())
                LoggingService.log("Requested to send data to watch, remaining transfers", with: transfersRemaining().description)
            } else {
                LoggingService.log("Complication NOT enabled", at: .debug)
            }
        #endif
    }
    
    public func notifyOtherDeviceOfGoalNotificaton() {
        send(message: WCSessionMessage.goalNotificationSent(dayKey: NotificationService.convertDayToKey(Date())), completionHandler: nil)
    }
    
    public func sendStepsGoal(goal: Steps) {
        send(message: WCSessionMessage.goalUpdate(goal: goal), completionHandler: nil)
    }
    
    public func triggerGoalNotificationOnWatch(day: Date) {
        #if os(iOS)
            send(message: WCSessionMessage.goalTrigger(day: day), completionHandler: nil)
        #endif
    }
    
    public func sendDebugLog(_ log: [DebugLogEntry], onCompletion: @escaping (Bool) -> ()) {
        send(message: WCSessionMessage.debugLog(entries: log), completionHandler: onCompletion)
    }
    
    public func toggleDebugMode(_ isOn: Bool) {
        send(message: WCSessionMessage.debugMode(isOn: isOn), completionHandler: nil)
    }
    
    private func send(message: WCSessionMessage, completionHandler: ((Bool) -> ())?) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated
        else {
            return
        }
        
        WCSession.default.sendMessage(message.message(),
                                      replyHandler: { _ in
                                        completionHandler?(true)
                                      },
                                      errorHandler: { err in
                                        LoggingService.log(error: err)
                                        completionHandler?(false)
        })
    }
    
    //MARK: Message parsing
    
    private func handle(message: [String : Any]) {
        guard let wcMessage = WCSessionMessage(rawMessage: message) else { return }
        
        var isWatch = true
        #if os(iOS)
            isWatch = false
        #endif
        
        switch wcMessage {
        
        case .complicationUpdate(let steps, let day) where day.isToday():
            LoggingService.log("Refreshing complication from received message", with: String(format: "%d", steps))
            StepsProcessingService.handleSteps(steps, for: day, from: "didReceiveUserInfo")
            
        case .goalUpdate(let goal):
            HealthCache.saveDailyGoal(goal)
        
        case .debugLog(let entries):
            LoggingService.mergeLog(newEntries: entries)
            
        case .debugMode(_):
            DebugService.toggleDebugMode()
            
        case .goalNotificationSent(let dayKey):
            NotificationService.markNotificationSentByOtherDevice(forKey: dayKey)
            
        case .goalTrigger(let day) where day.isToday() && isWatch:
            NotificationService.sendDailyStepsGoalNotification()
        
        default:
            return
            
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
            delegate?.sessionWasActivated()
        } else {
            if let e = error {
                LoggingService.log(error: e)
            }
            delegate?.sessionWasNotActivated()
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
            StepsProcessingService.triggerUpdate(from: "didReceiveUserInfo") { }
        #endif
        handle(message: userInfo)
    }

    public func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            LoggingService.log("WCSession transfer userInfo FAILED", with: error.localizedDescription)
        } else {
            LoggingService.log("WCSession transferred userInfo", with: userInfoTransfer.userInfo.keys.joined(separator: ", "))
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
