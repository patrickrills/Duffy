//
//  DebugLogEntry.swift
//  Duffy
//
//  Created by Patrick Rills on 12/21/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

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
    
    func serialize() -> [String : Any] {
        return [
            DebugLogEntry.messageKey : self.message,
            DebugLogEntry.timestampKey : NSNumber(value: self.timestamp.timeIntervalSinceReferenceDate)
        ]
    }
}
