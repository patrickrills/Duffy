//
//  WCSessionMessage.swift
//  Duffy
//
//  Created by Patrick Rills on 10/24/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

enum WCSessionMessage {
    case complicationUpdate(steps: Steps, day: Date)
    case goalUpdate(goal: Steps)
    case debugLog(entries: [DebugLogEntry])
    case debugMode(isOn: Bool)
    case goalNotificationSent(dayKey: String)
    case goalTrigger(day: Date)
    case systemVersionRequest
    case tippedOnWatch(tipId: TipIdentifier)
    
    init?(rawMessage: [String : Any]) {
        guard let messageKey = rawMessage.keys.first else { return nil }
        
        switch messageKey {
        
        case WCSessionMessageKeys.complicationUpdate.rawValue:
            if let dict = rawMessage[messageKey] as? [String: Any],
               let stepsValue = dict["steps"] as? Steps,
               let dayInterval = dict["day"] as? TimeInterval
            {
                self = .complicationUpdate(steps: stepsValue, day: Date(timeIntervalSinceReferenceDate: dayInterval))
            }
            else
            {
                fallthrough
            }
            
        case WCSessionMessageKeys.goalUpdate.rawValue:
            if let newGoal = rawMessage[messageKey] as? Steps {
                self = .goalUpdate(goal: newGoal)
            } else {
                fallthrough
            }
            
        case WCSessionMessageKeys.goalNotificationSent.rawValue:
            if let dayKey = rawMessage[messageKey] as? String {
                self = .goalNotificationSent(dayKey: dayKey)
            } else {
                fallthrough
            }
            
        case WCSessionMessageKeys.debugLog.rawValue:
            if let log = rawMessage[messageKey] as? [[String : Any]] {
                self = .debugLog(entries: log.map({ DebugLogEntry(deseralized: $0) }))
            } else {
                fallthrough
            }
            
        case WCSessionMessageKeys.debugMode.rawValue:
            if let isOn = rawMessage[messageKey] as? Int {
                self = .debugMode(isOn: isOn == 1)
            } else {
                fallthrough
            }
            
        case WCSessionMessageKeys.goalTrigger.rawValue:
            if let dayInterval = rawMessage[messageKey] as? TimeInterval {
                self = .goalTrigger(day: Date(timeIntervalSinceReferenceDate: dayInterval))
            } else {
                fallthrough
            }
            
        case WCSessionMessageKeys.systemVersionRequest.rawValue:
            self = .systemVersionRequest
            
        case WCSessionMessageKeys.tippedOnWatch.rawValue:
            if let rawId = rawMessage[messageKey] as? String,
               let tipId = TipIdentifier(rawValue: rawId)
            {
                self = .tippedOnWatch(tipId: tipId)
            } else {
                fallthrough
            }
            
        default:
            return nil
        }
        
    }
    
    func message() -> [String : Any] {
        switch self {
        case .complicationUpdate(let steps, let day):
            return [WCSessionMessageKeys.complicationUpdate.rawValue : ["steps" : steps, "day": day.timeIntervalSinceReferenceDate] as [String : Any]]
        case .goalUpdate(let goal):
            return [WCSessionMessageKeys.goalUpdate.rawValue : goal]
        case .debugLog(let entries):
            return [WCSessionMessageKeys.debugLog.rawValue : entries.map({ $0.serialize() })]
        case .debugMode(let isOn):
            return [WCSessionMessageKeys.debugMode.rawValue : isOn ? 1 : 0]
        case .goalNotificationSent(let dayKey):
            return [WCSessionMessageKeys.goalNotificationSent.rawValue : dayKey]
        case .goalTrigger(let day):
            return [WCSessionMessageKeys.goalTrigger.rawValue : day.timeIntervalSinceReferenceDate]
        case .systemVersionRequest:
            return [WCSessionMessageKeys.systemVersionRequest.rawValue : "1"]
        case .tippedOnWatch(let tipId):
            return [WCSessionMessageKeys.tippedOnWatch.rawValue : tipId.rawValue]
        }
    }
}

fileprivate enum WCSessionMessageKeys: String {
    case complicationUpdate = "stepsdataresponse"
    case goalUpdate = "stepsGoal"
    case debugLog = "watchDebugLog"
    case debugMode = "debugMode"
    case goalNotificationSent = "goalNotificationSent"
    case goalTrigger = "goalTrigger"
    case systemVersionRequest = "systemVersionRequest"
    case tippedOnWatch = "tippedOnWatch"
}
