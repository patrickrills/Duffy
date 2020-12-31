//
//  Globals.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 12/31/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation
import WatchKit

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
    
    static func roundedFont(of pointSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let rawFont = UIFont.systemFont(ofSize: pointSize, weight: weight)
        
        guard #available(watchOS 6.0, *),
              let roundedFontDescriptor = rawFont.fontDescriptor.withDesign(.rounded)
        else {
            return rawFont
        }
        
        return UIFont(descriptor: roundedFontDescriptor, size: pointSize)
    }
}
