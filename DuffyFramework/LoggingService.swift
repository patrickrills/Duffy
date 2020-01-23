//
//  LoggingService.swift
//  Duffy
//
//  Created by Patrick Rills on 10/9/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import Foundation
import os.log

open class LoggingService {
    
    open class func log(_ message: String) {
        log(message: message, extra: nil)
    }
    
    open class func log(_ message: String, with extra: String) {
        log(message: message, extra: extra)
    }
    
    open class func log(error: Error) {
        let nsError = error as NSError
        log(message: "Error", extra: String(format: "%@ (%@)", nsError.localizedDescription, nsError.code))
    }
    
    private static var LOGGING_PREFIX = "Duffy"
    
    private class func log(message: String, extra: String?) {
        var platform = "Watch"
        #if os(iOS)
            platform = "Phone"
        #endif
        
        if let extra = extra {
            os_log("%{public}@|%{public}@ %{public}@: %{public}@", LOGGING_PREFIX, platform, message, extra)
        } else {
            os_log("%{public}@|%{public}@ %{public}@", LOGGING_PREFIX, platform, message)
        }
        
        if DebugService.isDebugModeEnabled() {
            logDebug(message: message, extra: extra)
        }
    }
    
    private class func logDebug(message: String, extra: String?) {
        var platform = "Watch"
        #if os(iOS)
            platform = "Phone"
        #endif
        
        var formattedMessage: String
        let prefix = String(format: "%@ | %@", platform, message)
        if let extra = extra {
            formattedMessage = String(format: "%@: %@", prefix, extra)
        } else {
            formattedMessage = prefix
        }
        
        var log = getDebugLog()
        log.append(DebugLogEntry(message: formattedMessage, timestampInterval: Date().timeIntervalSinceReferenceDate))
        let serialized = log.map({ $0.serialize() })
        UserDefaults.standard.set(serialized, forKey: "debugLog")
    }
    
    open class func getDebugLog() -> [DebugLogEntry] {
        if let logDict = UserDefaults.standard.object(forKey: "debugLog") as? [[String : Any]]
        {
            return logDict.map({dict in
                return DebugLogEntry(deseralized: dict)
            }).sorted(by: {
                return $0.timestamp > $1.timestamp
            })
        }
        
        return []
    }
    
    open class func mergeLog(newEntries: [DebugLogEntry]) {
        var log = getDebugLog()
        let deltas = newEntries.filter({ !log.contains($0) })
        log.append(contentsOf: deltas)
        let serialized = log.map({ $0.serialize() })
        UserDefaults.standard.set(serialized, forKey: "debugLog")
    }
    
    open class func clearLog() {
        UserDefaults.standard.removeObject(forKey: "debugLog")
    }
}
