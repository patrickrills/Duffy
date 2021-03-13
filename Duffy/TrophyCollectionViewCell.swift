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
        
        let lastTemplate = "Last: %@"
        lastAwardLabel.text = String(format: lastTemplate, "...")
        
        HealthKitService.getInstance().lastAward(of: trophy) { [weak lastAwardLabel] result in
            let text: String
            var textColor: UIColor = .black
            switch result {
            case .success(let award) where award.trophy == trophy && award.lastAward != nil:
                text = String(format: lastTemplate, Globals.dayFormatter().string(from: award.lastAward!.day))
                if #available(iOS 13.0, *) {
                    textColor = .label
                }
            default:
                text = "Not awarded yet"
                if #available(iOS 13.0, *) {
                    textColor = .secondaryLabel
                }
            }
            
            DispatchQueue.main.async {
                lastAwardLabel?.text = text
                lastAwardLabel?.textColor = textColor
            }
        }
    }
}
