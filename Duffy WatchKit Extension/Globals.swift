//
//  Globals.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 12/31/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

enum Globals
{
    static let integerFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0        
        return numberFormatter
    }()
    
    static let decimalFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
    }()
}
