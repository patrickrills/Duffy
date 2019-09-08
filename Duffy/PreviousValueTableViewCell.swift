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
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    func bind(toDate: Date, steps: Int, goal: Int)
    {
        textLabel?.text = Globals.dayFormatter().string(from: toDate)
        textLabel?.textColor = Globals.primaryColor()
        textLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .regular)
        
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .label
        } else {
            detailTextLabel?.textColor = .black
        }
        
        let stepsFormatted = Globals.stepsFormatter().string(from: NSNumber(value: steps))!
        var detailWeight : UIFont.Weight = .regular
        
        if goal > 0, steps >= goal
        {
            detailTextLabel?.text = String(format: "%@ %@", HealthKitService.getInstance().getAdornment(for: steps), stepsFormatted)
            detailWeight = .semibold
        }
        else
        {
            detailTextLabel?.text = stepsFormatted
        }
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: detailWeight)
        
        selectionStyle = .none
        accessoryType = .none
    }
}
