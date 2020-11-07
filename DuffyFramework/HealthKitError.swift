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

extension HealthKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupported:
            return "Apple Health cannot be accessed from this device."
        case .unauthorized:
            return "Apple Health has not been authorized."
        case .invalidQuery, .invalidResults:
            return "Invalid query or results returned from Apple Health."
        case .wrapped(let error):
            return error.localizedDescription
        }
    }
}
