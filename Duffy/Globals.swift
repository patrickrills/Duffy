//
//  Globals.swift
//  Duffy
//
//  Created by Patrick Rills on 7/8/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

enum Globals
{
    private static let numberFormatter = NumberFormatter()
    private static let decimalFormatter = NumberFormatter()
    private static let pctFormatter = NumberFormatter()
    private static let dateFormatter = DateFormatter()
    private static let fullFormatter = DateFormatter()
    private static let mediumFormatter = DateFormatter()
    private static let shortFormatter = DateFormatter()
    private static let monthFormatter = DateFormatter()
    private static let secondary = UIColor(red: 76.0/255.0, green: 142.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    private static let success = UIColor(red: 0.25, green: 0.72, blue:0.48, alpha: 1.0)
    
    static func stepsFormatter() -> NumberFormatter
    {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter
    }
    
    static func flightsFormatter() -> NumberFormatter
    {
        return stepsFormatter()
    }
    
    static func distanceFormatter() -> NumberFormatter
    {
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 1
        
        return decimalFormatter
    }
    
    static func trophyFactorFormatter() -> NumberFormatter
    {
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 2
        
        return decimalFormatter
    }
    
    static func percentFormatter() -> NumberFormatter
    {
        pctFormatter.numberStyle = .percent
        pctFormatter.maximumFractionDigits = 0
        pctFormatter.roundingMode = .halfUp
        pctFormatter.negativePrefix = ""
        
        return pctFormatter
    }
    
    static func dayFormatter() -> DateFormatter
    {
        dateFormatter.setLocalizedDateFormatFromTemplate("eee, MMM d")
        return dateFormatter
    }
    
    static func fullDateFormatter() -> DateFormatter
    {
        fullFormatter.dateStyle = .long
        return fullFormatter
    }
    
    static func mediumDateFormatter() -> DateFormatter
    {
        mediumFormatter.dateStyle = .medium
        return mediumFormatter
    }
    
    static func shortDateFormatter() -> DateFormatter
    {
        shortFormatter.setLocalizedDateFormatFromTemplate("MMM d")
        return shortFormatter
    }
    
    static func monthYearFormatter() -> DateFormatter
    {
        monthFormatter.setLocalizedDateFormatFromTemplate("MMM yyyy")
        return monthFormatter
    }
 
    static func primaryColor() -> UIColor
    {
        if let primaryColor = UIColor(named: "PrimaryColor") {
            return primaryColor
        }
        
        return .systemBlue
    }
    
    static func secondaryColor() -> UIColor
    {
        if let secondaryColor = UIColor(named: "SecondaryColor") {
            return secondaryColor
        }
        
        return secondary
    }
    
    static func averageColor() -> UIColor
    {
        if let averageColor = UIColor(named: "AverageColor") {
            return averageColor
        }
        
        return .systemPurple
    }
    
    static func trendColor() -> UIColor
    {
        if let trendColor = UIColor(named: "TrendColor") {
            return trendColor
        }
        
        return .systemTeal
    }
    
    static func lightGrayColor() -> UIColor
    {
        return .tertiaryLabel
    }
    
    static func veryLightGrayColor() -> UIColor
    {
        return .quaternaryLabel
    }
    
    static func successColor() -> UIColor
    {
        if let successColor = UIColor(named: "SuccessColor") {
            return successColor
        }
        
        return .systemYellow
    }
    
    static func separatorColor() -> UIColor
    {
        return .opaqueSeparator
    }
    
    static func iconColor() -> UIColor
    {
        if let iconColor = UIColor(named: "IconColor") {
            return iconColor
        }
        
        return lightGrayColor()
    }
    
    static func isNarrowPhone() -> Bool
    {
        return UIScreen.main.bounds.size.width <= 320.0
    }
    
    static func isTallPhone() -> Bool
    {
        return UIScreen.main.bounds.size.height > 700.0
    }
    
    static func isMaxPhone() -> Bool
    {
        return UIScreen.main.bounds.size.height > 850.0
    }
    
    static func appVersion() -> String
    {
        if let infoDict = Bundle.main.infoDictionary
        {
            if let ver1 = infoDict["CFBundleShortVersionString"] as? String,
                let ver2 = infoDict["CFBundleVersion"] as? String
            {
                return String(format: "%@.%@", ver1, ver2)
            }
        }
        
        return "Unknown"
    }
    
    private static let WATCH_VERSION_KEY = "WatchVersion"
    
    static func watchSystemVersion() -> Double {
        return UserDefaults.standard.double(forKey: WATCH_VERSION_KEY)
    }
    
    static func setWatchSystemVersion(_ version: Double) {
        if version > 0.0 {
            UserDefaults.standard.set(version, forKey: WATCH_VERSION_KEY)
        }
    }
    
    static func tableViewStyle() -> UITableView.Style {
        return .insetGrouped
    }
}
