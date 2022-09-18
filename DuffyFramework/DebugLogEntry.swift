//
//  DebugLogEntry.swift
//  Duffy
//
//  Created by Patrick Rills on 12/21/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

public class DebugLogEntry: NSObject {
    public var message: String
    public var timestamp: Date
    
    static let messageKey = "Debug_Message"
    static let timestampKey = "Debug_Timestamp"
    
    convenience init(deseralized: [String : Any]) {
        var m = ""
        var t: TimeInterval = 0
        
        if let message = deseralized[DebugLogEntry.messageKey] as? String {
            m = message
        }
        
        if let timestamp = deseralized[DebugLogEntry.timestampKey] as? NSNumber {
            t = timestamp.doubleValue
        }
        
        self.init(message: m, timestampInterval: t)
    }
    
    init(message: String, timestampInterval: TimeInterval) {
        self.message = message
        self.timestamp = Date(timeIntervalSinceReferenceDate: timestampInterval)
    }
    
    public func serialize() -> [String : Any] {
        return [
            DebugLogEntry.messageKey : self.message,
            DebugLogEntry.timestampKey : NSNumber(value: self.timestamp.timeIntervalSinceReferenceDate)
        ]
    }
    
    public func textColor() -> UIColor {
        #if os(iOS)
            let isOpen = self.message.contains("App will enter foreground") || self.message.contains("App did finish launching")
            let isClose = self.message.contains("App will resign active")
            let isSendComplication = self.message.contains("updateWatchFaceComplication")
            let isReloadComplication = self.message.contains("reloadTimeline")
            let isCoreMotion = self.message.contains("CMPedometer")
        
            if isOpen {
                return .systemGreen
            } else if isClose {
                return .systemRed
            } else if isSendComplication {
                return .systemPurple
            } else if isReloadComplication {
                return .systemTeal
            } else if isCoreMotion {
                return .systemOrange
            } else {
                return .label
            }
        #else
            return .white
        #endif
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let otherLog = object as? DebugLogEntry else { return false }
        return self.message == otherLog.message && self.timestamp.timeIntervalSinceReferenceDate == otherLog.timestamp.timeIntervalSinceReferenceDate
    }
}
