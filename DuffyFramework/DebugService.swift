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
}
