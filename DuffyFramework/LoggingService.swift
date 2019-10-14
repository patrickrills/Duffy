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
    }
}
