//
//  TrophyLegendView.swift
//  Duffy
//
//  Created by Patrick Rills on 5/8/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TrophyLegendView: UIView {

    @IBOutlet var fourLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    class func createView() -> TrophyLegendView? {
        if let nibViews = Bundle.main.loadNibNamed("TrophyLegendView", owner:nil, options:nil),
            let trophyView = nibViews[0] as? TrophyLegendView {
            trophyView.translatesAutoresizingMaskIntoConstraints = false
            return trophyView
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stepGoalFormatted = Globals.stepsFormatter().string(from: NSNumber(value: HealthCache.getStepsDailyGoal()))!
        descriptionLabel.text = String(format: NSLocalizedString("When you've reached your goal, you'll earn a trophy based on how many steps you've taken beyond your goal (%@).", comment: "Placeholder is a number of steps: ie 10,000"), stepGoalFormatted)
    }
}
