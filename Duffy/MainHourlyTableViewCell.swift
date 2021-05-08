//
//  MainHourlyTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 4/17/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class MainHourlyTableViewCell: UITableViewCell {

    @IBOutlet weak var barsStackView : UIStackView!
    @IBOutlet weak var maxIndicator : HourGraphMaxIndicatorView!
    @IBOutlet weak var noStepsLabel : UILabel!
    @IBOutlet weak var sixAMLabel : UILabel!
    @IBOutlet weak var noonLabel : UILabel!
    @IBOutlet weak var sixPMLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        noStepsLabel.textColor = Globals.lightGrayColor()
        noStepsLabel.text = NSLocalizedString("No Steps Today", comment: "")
        sixAMLabel.text = NSLocalizedString("6 AM", comment: "")
        noonLabel.text = NSLocalizedString("NOON", comment: "")
        sixPMLabel.text = NSLocalizedString("6 PM", comment: "")
    }

    func bind(stepsByHour: [Hour : Steps]) {
        var max: Steps = 0
        
        if stepsByHour.count > 0,
           let maxStepsInAnHour = stepsByHour.values.max()
        {
            max = maxStepsInAnHour
        }
        
        if (max > 0) {
            maxIndicator.max = max
            maxIndicator.isHidden = false
            noStepsLabel.isHidden = true
        } else {
            maxIndicator.isHidden = true
            noStepsLabel.isHidden = false
        }
        
        var runningStepTotal: Steps = 0
        var reachedGoal = false
        let goal = HealthCache.dailyGoal()
        
        barsStackView
            .arrangedSubviews
            .compactMap {
                $0 as? HourGraphBarView
            }
            .enumerated()
            .forEach { idx, bar in
                var percent : CGFloat = 0.0
                
                if let steps = stepsByHour[Hour(idx)] {
                    runningStepTotal += steps
                    
                    if max > 0 {
                        percent = CGFloat(CGFloat(steps) / CGFloat(max))
                    }
                }
                
                bar.percent = percent
                
                if runningStepTotal >= goal,
                   !reachedGoal
                {
                    bar.color = Globals.successColor()
                    reachedGoal = true
                } else {
                    bar.color = Globals.primaryColor()
                }
        }
    }
    
}
