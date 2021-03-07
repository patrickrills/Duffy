//
//  TrophyCollectionViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 3/7/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TrophyCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var factorLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastAwardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            backgroundColor = .secondarySystemGroupedBackground
        } else {
            backgroundColor = .white
        }
        
        layer.cornerRadius = 10.0
        clipsToBounds = true
    }

    func bind(to trophy: Trophy) {
        symbolLabel.text = trophy.symbol()
        factorLabel.text = Globals.trophyFactorFormatter().string(for: trophy.factor())! + "x!"
        descriptionLabel.text = "Your Goal".uppercased()
        lastAwardLabel.text = "TODO"
    }
}
