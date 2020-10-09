//
//  LoggingService.swift
//  Duffy
//
//  Created by Patrick Rills on 10/9/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import Foundation
import os.log

public class LoggingService {
    
    public class func log(_ message: String) {
        log(level: .tracing, message: message, extra: nil)
    }
    
    public class func log(_ message: String, at level: LogLevel) {
        log(level: level, message: message, extra: nil)
    }
    
    public class func log(_ message: String, with extra: String) {
        log(level: .debug, message: message, extra: extra)
    }
    
    public class func log(error: Error) {
        let nsError = error as NSError
        log(level: .error, message: "Error", extra: String(format: "%@ (%d)", nsError.localizedDescription, nsError.code))
    }
    
    private static let MAX_DAYS_WATCH = 1
    private static let MAX_DAYS_PHONE = 3
    private static var LOGGING_PREFIX = "Duffy"
    private static let logger = OSLog(subsystem: "com.bigbluefly.Duffy", category: LOGGING_PREFIX)
    
    private class func log(level: LogLevel, message: String, extra: String?) {
        guard level.shouldLog() else {
            return
        }
        
        var platform = "Watch"
        #if os(iOS)
            platform = "Phone"
        #endif
        
        if let extra = extra {
            os_log("%{public}@ %{public}@: %{public}@", log: logger, platform, message, extra)
        } else {
            os_log("%{public}@ %{public}@", log: logger, platform, message)
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
        
        var log = purge(log: getFullDebugLog())
        log.append(DebugLogEntry(message: formattedMessage, timestampInterval: Date().timeIntervalSinceReferenceDate))
        let serialized = log.map({ $0.serialize() })
        UserDefaults.standard.set(serialized, forKey: "debugLog")
    }
    
    private class func purge(log: [DebugLogEntry]) -> [DebugLogEntry] {
        var maxDays = MAX_DAYS_WATCH
        #if os(iOS)
            maxDays = MAX_DAYS_PHONE
        #endif
        
        let filterDate = Calendar.current.date(byAdding: .day, value: -maxDays, to: Date().stripTime())!
        return log.filter({ $0.timestamp > filterDate })
    }
    
    public class func getFullDebugLog() -> [DebugLogEntry] {
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
    
    public class func getPartialDebugLog(from startDate: Date, to endDate: Date) -> [DebugLogEntry] {
        let startComponents = Calendar.current.dateComponents([.era, .year, .month, .day], from: startDate)
        let endDateCompentents = Calendar.current.dateComponents([.era, .year, .month, .day], from: endDate)
        
        guard let filterStartDate = Calendar.current.date(from: startComponents),
            let rawEndDate = Calendar.current.date(from: endDateCompentents),
            let filterEndDate = Calendar.current.date(byAdding: .day, value: 1, to: rawEndDate)
            else {
            return []
        }
       
        return getFullDebugLog().filter({
            $0.timestamp >= filterStartDate && $0.timestamp < filterEndDate
        })
    }
    
    public class func getDatesFromDebugLog() -> [Date] {
        let allDates:[Date] = getFullDebugLog().compactMap({
            let components = Calendar.current.dateComponents([.era, .year, .month, .day], from: $0.timestamp)
            return Calendar.current.date(from: components)
        })
        return Array(Set(allDates)).sorted(by: >)
    }
    
    public class func mergeLog(newEntries: [DebugLogEntry]) {
        var log = getFullDebugLog()
        let deltas = newEntries.filter({ !log.contains($0) })
        log.append(contentsOf: deltas)
        let serialized = log.map({ $0.serialize() })
        UserDefaults.standard.set(serialized, forKey: "debugLog")
    }
    
    public class func clearLog() {
        UserDefaults.standard.removeObject(forKey: "debugLog")
    }
}
