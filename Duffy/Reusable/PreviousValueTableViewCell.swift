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
    static let rowHeight: CGFloat = 44.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func bind(to date: Date, steps: Steps, goal: Steps) {
        let trophy = Trophy.trophy(for: steps)
        let stepsFormatted = Globals.stepsFormatter().string(for: steps)!
        let primaryText = String(format: "%@ %@", stepsFormatted, trophy.symbol()).trimmingCharacters(in: .whitespaces)
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
        let weight: UIFont.Weight = trophy == .none ? .regular : .semibold
        return UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: weight)
    }
}
