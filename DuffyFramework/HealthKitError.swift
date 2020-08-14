//
//  HealthKitError.swift
//  Duffy
//
//  Created by Patrick Rills on 8/14/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public enum HealthKitError: Error {
    case unsupported
    case unauthorized
    case invalidQuery
    case invalidResults
    case wrapped(Error)
}
