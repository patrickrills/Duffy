//
//  StoreKitError.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation

public enum StoreKitError: Error {
    case productDownloadFailed
    case purchaseFailed
    case wrapped(Error)
}

extension StoreKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .productDownloadFailed:
            return "Could not download product information from store."
        case .purchaseFailed:
            return "The purchase could not be completed."
        case .wrapped(let error):
            return error.localizedDescription
        }
    }
}
