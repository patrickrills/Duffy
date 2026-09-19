//
//  GoalInstructionsTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 2/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class GoalInstructionsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var instructionsLabel: UILabel!
    @IBOutlet private weak var screenshot: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberLabel.textColor = Globals.lightGrayColor()
        
        screenshot.clipsToBounds = true
        screenshot.layer.cornerRadius = 8.0
        selectionStyle = .none
    }
 
    func bind(to step: GoalInstructions) {
        numberLabel.text = Globals.stepsFormatter().string(for: step.rawValue)
        instructionsLabel.text = step.text()
        screenshot.image = step.screenshot()
    }
    
}
