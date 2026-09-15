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
    private static let DEBUG_LOG_KEY = "debugLog"
    private static let debugLogLock = NSLock()
    private static let logger = OSLog(subsystem: "com.bigbluefly.Duffy", category: LOGGING_PREFIX)
    
    private class func log(level: LogLevel, message: String, extra: String?) {
        guard level.shouldLog() else {
            return
        }
        
        var platform = "Watch"
        #if os(iOS)
            platform = "Phone"
        #endif
        
        var isWidget = false
        if message.starts(with: LogLevel.widgetPrefix) {
            platform += " Widget"
            isWidget = true
        }
        
        if let extra = extra {
            os_log("%{public}@ %{public}@: %{public}@", log: logger, platform, message, extra)
        } else {
            os_log("%{public}@ %{public}@", log: logger, platform, message)
        }
        
        if DebugService.isDebugModeEnabled() {
            logDebug(message: message, extra: extra, shared: isWidget)
        }
    }
    
    private class func logDebug(message: String, extra: String?, shared: Bool = false) {
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
        
        let defaults: UserDefaults
        if shared, let shared = UserDefaults(suiteName: Constants.sharedGroupName) {
            defaults = shared
        } else {
            defaults = .standard
        }

        debugLogLock.lock()
        defer { debugLogLock.unlock() }

        var log = purge(log: getDebugLog(from: defaults))
        log.append(DebugLogEntry(message: formattedMessage, timestampInterval: Date().timeIntervalSinceReferenceDate))
        defaults.set(log.map({ $0.serialize() }), forKey: DEBUG_LOG_KEY)
    }
    
    private class func purge(log: [DebugLogEntry]) -> [DebugLogEntry] {
        var maxDays = MAX_DAYS_WATCH
        #if os(iOS)
            maxDays = MAX_DAYS_PHONE
        #endif
        
        let filterDate = Calendar.current.date(byAdding: .day, value: -maxDays, to: Date().stripTime())!
        return log.filter({ $0.timestamp > filterDate })
    }
    
    public class func getMergedDebugLog() -> [DebugLogEntry] {
        let sharedEntries = getSharedDebugLog()
        if sharedEntries.count > 0 {
            mergeLog(newEntries: sharedEntries)
        }
        return getFullDebugLog()
    }
    
    public class func getFullDebugLog() -> [DebugLogEntry] {
        return getDebugLog(from: .standard)
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
       
        return getMergedDebugLog().filter({
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
    
    private class func getSharedDebugLog() -> [DebugLogEntry] {
        guard let shared = UserDefaults(suiteName: Constants.sharedGroupName) else {
            return []
        }

        return getDebugLog(from: shared)
    }

    private class func getDebugLog(from defaults: UserDefaults) -> [DebugLogEntry] {
        guard let logDict = defaults.object(forKey: DEBUG_LOG_KEY) as? [[String : Any]] else {
            return []
        }

        return logDict.map({ DebugLogEntry(deseralized: $0) }).sorted(by: {
            return $0.timestamp > $1.timestamp
        })
    }
    
    public class func mergeLog(newEntries: [DebugLogEntry]) {
        debugLogLock.lock()
        defer { debugLogLock.unlock() }

        var log = getFullDebugLog()
        let deltas = newEntries.filter({ !log.contains($0) })
        log.append(contentsOf: deltas)
        let serialized = log.map({ $0.serialize() })
        UserDefaults.standard.set(serialized, forKey: DEBUG_LOG_KEY)
    }
    
    public class func clearLog() {
        debugLogLock.lock()
        defer { debugLogLock.unlock() }

        UserDefaults.standard.removeObject(forKey: DEBUG_LOG_KEY)
        if let shared = UserDefaults(suiteName: Constants.sharedGroupName) {
            shared.removeObject(forKey: DEBUG_LOG_KEY)
        }
    }
}
