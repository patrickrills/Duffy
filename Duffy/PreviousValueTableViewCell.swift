//
//  PreviousValueTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 7/8/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class PreviousValueTableViewCell: UITableViewCell
{
    static let rowHeight: CGFloat = 44.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    func bind(toDate: Date, steps: Steps, goal: Int) {
        textLabel?.text = Globals.dayFormatter().string(from: toDate)
        textLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
        
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .label
            textLabel?.textColor = .secondaryLabel
        } else {
            detailTextLabel?.textColor = .black
            textLabel?.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        }
        
        let stepsFormatted = Globals.stepsFormatter().string(from: NSNumber(value: steps))!
        var detailWeight : UIFont.Weight = .regular
        
        if goal > 0, steps >= goal{
            detailTextLabel?.text = String(format: "%@ %@", Trophy.trophy(for: Int(steps)).symbol(), stepsFormatted)
            detailWeight = .semibold
        } else {
            detailTextLabel?.text = stepsFormatted
        }
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: detailWeight)
        
        selectionStyle = .none
        accessoryType = .none
    }
}
