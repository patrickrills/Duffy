//
//  AggregateCollections.swift
//  Duffy
//
//  Created by Patrick Rills on 8/14/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public extension Collection where Element: AdditiveArithmetic {
    func sum() -> Element {
        return reduce(.zero, +)
    }
}

public extension Collection where Element: BinaryInteger {
    func mean() -> Double {
        guard !isEmpty else { return .zero }
        return Double(sum()) / Double(count)
    }
}

public extension Collection where Element: FloatingPoint {
    func mean() -> Element {
        guard !isEmpty else { return .zero }
        return sum() / Element(count)
    }
}
