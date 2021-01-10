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
    
    static let summaryDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEEE" //TODO: One letter? "EEEEE"
        dateFormatter.locale = Locale.current
        return dateFormatter
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
    
    static func primaryColor() -> UIColor {
        guard let primary = UIColor(named: "PrimaryColor") else {
            return .blue
        }
        
        return primary
    }
    
    static func secondaryColor() -> UIColor {
        guard let secondary = UIColor(named: "SecondaryColor") else {
            return .darkGray
        }
        
        return secondary
    }
    
    static func dividerColor() -> UIColor {
        guard let divider = UIColor(named: "DividerColor") else {
            return .lightGray
        }
        
        return divider
    }
    
    static func goalColor() -> UIColor {
        guard let goalColor = UIColor(named: "GoalColor") else {
            return .yellow
        }
        
        return goalColor
    }
}
