//
//  GoalInstructionsTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 2/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class GoalInstructionsTableViewCell: UITableViewCell {
    
    static let CELL_HEIGHT: CGFloat = 131.0
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var instructionsLabel: UILabel!
    @IBOutlet private weak var screenshot: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberLabel.textColor = Globals.primaryColor()
    }
 
    func bind(to step: GoalInstructions, useLegacyInstructions: Bool) {
        numberLabel.text = Globals.stepsFormatter().string(for: step.rawValue)
        instructionsLabel.text = step.text(useLegacyInstructions: useLegacyInstructions)
        screenshot.image = step.screenshot(useLegacyInstructions: useLegacyInstructions)
    }
}
