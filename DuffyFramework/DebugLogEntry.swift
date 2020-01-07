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
            let isComplication = self.message.contains("updateWatchFaceComplication")
        
            if isOpen {
                return .systemGreen
            } else if isClose {
                return .systemRed
            } else if isComplication {
                return .systemPurple
            } else {
                if #available(iOS 13.0, *) {
                    return .label
                } else {
                    return .black
                }
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
