//
//  DebugService.swift
//  Duffy
//
//  Created by Patrick Rills on 1/14/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

open class DebugService {
    
    private static let DEBUG_MODE_KEY = "debugMode"
    
    open class func isDebugModeEnabled() -> Bool {
        if Constants.isDebugMode {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: DEBUG_MODE_KEY)
    }
    
    open class func toggleDebugMode() {
        let mode = UserDefaults.standard.bool(forKey: DEBUG_MODE_KEY)
        let newMode = !mode
        UserDefaults.standard.set(newMode, forKey: DEBUG_MODE_KEY)
        #if os(iOS)
            let newModeInt = newMode ? 1 : 0
            WCSessionService.getInstance().send(message: DEBUG_MODE_KEY, payload: newModeInt, onCompletion:{ (_) in })
        #endif
    }
    
    open class func exportLogToCSV() -> URL? {
        let log = LoggingService.getFullDebugLog()
        let columns = ["RowId", "Timestamp", "Platform", "Message", "Extra"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        var rows = [[String]]()
        for (index, item) in log.enumerated() {
            var row = [String]()
            var platform = ""
            var message = item.message
            var extra = ""
            
            if let platformIndex = message.firstIndex(of: "|") {
                platform = String(message[..<platformIndex]).trimmingCharacters(in: .whitespaces)
                message = String(message[message.index(after: platformIndex)...]).trimmingCharacters(in: .whitespaces)
            }
            
            if let extraIndex = message.lastIndex(of: ":") {
                extra = String(message[message.index(after: extraIndex)...])
                message = String(message[..<extraIndex])
            }
            
            row.append(String(format: "%d", index))
            row.append(dateFormatter.string(from: item.timestamp))
            row.append(platform)
            row.append(message)
            row.append(extra)
            rows.append(row)
        }
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            case let fullPath = String(format: "%@/log.csv", path),
            ExportService.toCSV(rows, columns: columns, saveAs: fullPath) {
            
            return URL(fileURLWithPath: fullPath)
        }
        
        return nil
    }
}
