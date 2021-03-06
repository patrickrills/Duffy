//
//  TipOption.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation

public struct TipOption {
    public let identifier: TipIdentifier
    public let formattedPrice: String
    public let price: Double
}

public enum TipIdentifier: String, CaseIterable {
    case oneDollar = "com.bigbluefly.tipOne"
    case twoDollars = "com.bigbluefly.tipTwo"
    case threeDollars = "com.bigbluefly.tipThree"
    case fiveDollars = "com.bigbluefly.tipFive"
}
