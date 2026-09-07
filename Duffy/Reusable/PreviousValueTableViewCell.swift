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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func bind(to date: Date, steps: Steps, goal: Steps) {
        bind(to: date, value: Globals.stepsFormatter().string(for: steps)!, trophy: Trophy.trophy(for: steps))
    }
    
    func bind(to date: Date, value: String, trophy: Trophy) {
        let primaryText = String(format: "%@ %@", value, trophy.symbol()).trimmingCharacters(in: .whitespaces)
        let secondaryText = Globals.dayFormatter().string(from: date)
        let primaryFont = font(for: trophy)
        
        selectionStyle = .none
        accessoryType = .none
        
        var valueContentConfig = UIListContentConfiguration.valueCell()
        valueContentConfig.text = primaryText
        valueContentConfig.secondaryText = secondaryText
        valueContentConfig.textProperties.font = primaryFont
        contentConfiguration = valueContentConfig
    }
    
    private func font(for trophy: Trophy) -> UIFont {
        let weight: UIFontDescriptor.SymbolicTraits = trophy != .none ? .traitBold : []
        
        guard let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withSymbolicTraits(weight) else {
            return UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
        
        return UIFont(descriptor: descriptor, size: 0.0)
    }
}
