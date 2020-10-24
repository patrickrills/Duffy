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
            
        default:
            return nil
        }
        
    }
    
    func message() -> [String : Any] {
        switch self {
        case .complicationUpdate(let steps, let day):
            return [WCSessionMessageKeys.complicationUpdate.rawValue : ["steps" : steps, "day": day.timeIntervalSinceReferenceDate]]
        case .goalUpdate(let goal):
            return [WCSessionMessageKeys.goalUpdate.rawValue : goal]
        case .debugLog(let entries):
            return [WCSessionMessageKeys.debugLog.rawValue : entries.map({ $0.serialize() })]
        case .debugMode(let isOn):
            return [WCSessionMessageKeys.debugMode.rawValue : isOn ? 1 : 0]
        case .goalNotificationSent(let dayKey):
            return [WCSessionMessageKeys.goalNotificationSent.rawValue : dayKey]
        }
    }
}

fileprivate enum WCSessionMessageKeys: String {
    case complicationUpdate = "stepsdataresponse"
    case goalUpdate = "stepsGoal"
    case debugLog = "watchDebugLog"
    case debugMode = "debugMode"
    case goalNotificationSent = "goalNotificationSent"
}
