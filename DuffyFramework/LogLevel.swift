//
//  LogLevel.swift
//  Duffy
//
//  Created by Patrick Rills on 6/27/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

enum LogLevel {
    case tracing, debug, error
    
    public func shouldLog() -> Bool {
        switch self {
        case .error:
            return true
        case .tracing, .debug:
            return DebugService.isDebugModeEnabled()
        }
    }
}
