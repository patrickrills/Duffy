//
//  TrophyItemView.swift
//  Duffy
//
//  Created by Patrick Rills on 5/10/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TrophyItemView: UIView {
    
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var stepsLabel: UILabel!
    @IBOutlet private weak var percentLabel: UILabel!
    
    var trophy: Trophy = .none {
        didSet {
            bind(to: trophy)
        }
    }
    
    class func createView(for trophy: Trophy) -> TrophyItemView? {
        if let nibViews = Bundle.main.loadNibNamed("TrophyItemView", owner:nil, options:nil),
            let trophyView = nibViews[0] as? TrophyItemView {
            trophyView.translatesAutoresizingMaskIntoConstraints = false
            trophyView.trophy = trophy
            return trophyView
        }
        
        return nil
    }
    
    private func bind(to trophy: Trophy) {
        symbolLabel.text = trophy.symbol()
        stepsLabel.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), Globals.stepsFormatter().string(for: trophy.stepsRequired())!).lowercased()
        percentLabel.text = trophy.description()
        percentLabel.textColor = Globals.primaryColor()
        if trophy == .shoe {
            if #available(iOS 13.0, *) {
                percentLabel.textColor = .secondaryLabel
            }
        }
    }
}
