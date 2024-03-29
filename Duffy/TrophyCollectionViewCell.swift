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
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var symbolSize: NSLayoutConstraint!
    @IBOutlet private weak var factorTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var factorHeight: NSLayoutConstraint!
    @IBOutlet private weak var descriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var factorMargin: NSLayoutConstraint!
    @IBOutlet private weak var lastAwardTopConstraint: NSLayoutConstraint!
    
    private var isBigMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 10.0
        clipsToBounds = true
    }

    func bind(to trophy: Trophy, isBig: Bool, last: (isLoading: Bool, award: LastAward?)) {
        isBigMode = isBig
        setNeedsUpdateConstraints()
        
        let formattedFactor = Globals.trophyFactorFormatter().string(for: trophy.factor())!
        
        symbolLabel.text = trophy.symbol()
        factorLabel.text = isBig
                            ? String(format: NSLocalizedString("%@x your goal!", comment: ""), formattedFactor)
                            : formattedFactor + "x!"
        
        descriptionLabel.text = isBig
                                ? trophy.description()
                                : NSLocalizedString("Your Goal", comment: "").uppercased()
        
        let lastTemplate = NSLocalizedString("Last: %@", comment: "")
        let text: String
        var textColor: UIColor = .label
        
        if last.isLoading {
            text = String(format: lastTemplate, "...")
        } else if let award = last.award {
            let awardDate = award.day
            let dateFormatter = awardDate.differenceInDays(from: Date()) < 365
                ? Globals.dayFormatter()
                : Globals.monthYearFormatter()
            text = String(format: lastTemplate, dateFormatter.string(from: awardDate))
        } else {
            text = NSLocalizedString("Not awarded yet", comment: "")
            textColor = .secondaryLabel
        }
        
        lastAwardLabel.text = text
        lastAwardLabel.textColor = textColor
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let layoutSpecs = isBigMode
                            ? LayoutSpecs.bigModeLayoutSpecs()
                            : LayoutSpecs.baseLayoutSpecs()
        
        topConstraint.constant = layoutSpecs.topMargin
        symbolSize.constant = layoutSpecs.symbolSize
        symbolLabel.font = UIFont.systemFont(ofSize: layoutSpecs.symbolFontSize)
        factorTopConstraint.constant = layoutSpecs.factorTopMargin
        descriptionTopConstraint.constant = layoutSpecs.descriptionTopMargin
        factorMargin.constant = layoutSpecs.factorLeadingMargin
        factorHeight.constant = layoutSpecs.factorHeight
        lastAwardLabel.font = UIFont.systemFont(ofSize: layoutSpecs.lastAwardFontSize)
        lastAwardTopConstraint.constant = layoutSpecs.lastAwardTopMargin
    }
}

fileprivate struct LayoutSpecs {
    let topMargin: CGFloat
    let symbolSize: CGFloat
    let symbolFontSize: CGFloat
    let factorTopMargin: CGFloat
    let factorLeadingMargin: CGFloat
    let factorHeight: CGFloat
    let descriptionTopMargin: CGFloat
    let lastAwardFontSize: CGFloat
    let lastAwardTopMargin: CGFloat
    
    private enum BaseSpecs {
        static let TOP_MARGIN: CGFloat = 12.0
        static let SYMBOL_SIZE: CGFloat = 36.0
        static let SYMBOL_FONT: CGFloat = 32.0
        static let LEFT_MARGIN: CGFloat = 4.0
        static let LAST_AWARD_MARGIN: CGFloat = 4.0
    }
    
    static func bigModeLayoutSpecs() -> LayoutSpecs {
        return LayoutSpecs(topMargin: BaseSpecs.TOP_MARGIN * 2.0, symbolSize: BaseSpecs.SYMBOL_SIZE * 2.0, symbolFontSize: BaseSpecs.SYMBOL_FONT * 2.0, factorTopMargin: 18.0, factorLeadingMargin: BaseSpecs.LEFT_MARGIN * 2.0, factorHeight: 24, descriptionTopMargin: 6, lastAwardFontSize: 14, lastAwardTopMargin: BaseSpecs.LAST_AWARD_MARGIN * 2.0)
    }
    
    static func baseLayoutSpecs() -> LayoutSpecs {
        return LayoutSpecs(topMargin: BaseSpecs.TOP_MARGIN, symbolSize: BaseSpecs.SYMBOL_SIZE, symbolFontSize: BaseSpecs.SYMBOL_FONT, factorTopMargin: 0, factorLeadingMargin: BaseSpecs.LEFT_MARGIN, factorHeight: 20, descriptionTopMargin: 0, lastAwardFontSize: 12, lastAwardTopMargin: BaseSpecs.LAST_AWARD_MARGIN)
    }
}
