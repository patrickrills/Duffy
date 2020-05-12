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
    @IBOutlet var legendStackView: UIStackView!
    @IBOutlet private weak var instructionNumberWidth: NSLayoutConstraint!
    @IBOutlet private weak var instructionNumberMargin: NSLayoutConstraint!
    
    class func createView(showInstructionNumber: Bool) -> TrophyLegendView? {
        if let nibViews = Bundle.main.loadNibNamed("TrophyLegendView", owner:nil, options:nil),
            let trophyView = nibViews[0] as? TrophyLegendView {
            trophyView.translatesAutoresizingMaskIntoConstraints = false
            if !showInstructionNumber {
                trophyView.instructionNumberWidth.constant = 0.0
                trophyView.instructionNumberMargin.constant = 0.0
            }
            return trophyView
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stepGoal = HealthCache.getStepsDailyGoal()
        let stepGoalFormatted = Globals.stepsFormatter().string(for: stepGoal)!
        descriptionLabel.text = String(format: NSLocalizedString("When you've reached your goal, you'll earn a trophy based on how many steps you've taken beyond your goal (%@).", comment: "Placeholder is a number of steps: ie 10,000"), stepGoalFormatted)
        Trophy.allCases.filter({ $0 != .none }).forEach({
            [weak self] t in
            self?.createLegendEntry(for: t)
        })
    }
    
    private func createLegendEntry(for trophy: Trophy) {
        guard let trophyItem = TrophyItemView.createView(for: trophy) else {
            return
        }
        
        legendStackView.addArrangedSubview(trophyItem)
    }
}
