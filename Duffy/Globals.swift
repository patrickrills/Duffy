//
//  Globals.swift
//  Duffy
//
//  Created by Patrick Rills on 7/8/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class Globals: NSObject
{
    private static let numberFormatter = NumberFormatter()
    private static let dateFormatter = DateFormatter()
    private static let primary = UIColor(red: 0.0, green: 61.0/255.0, blue: 165.0/255.0, alpha: 1.0)
    private static let secondary = UIColor(red: 76.0/255.0, green: 142.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    
    open class func stepsFormatter() -> NumberFormatter
    {
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter
    }
    
    open class func dayFormatter() -> DateFormatter
    {
        dateFormatter.dateFormat = "eee, MMM d"
        return dateFormatter
    }
 
    open class func primaryColor() -> UIColor
    {
        return primary
    }
    
    open class func secondaryColor() -> UIColor
    {
        return secondary
    }
}
