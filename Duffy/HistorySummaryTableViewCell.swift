//
//  HistorySummaryTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 8/23/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistorySummaryTableViewCell: UITableViewCell {

    @IBOutlet private weak var averageLabel : UILabel!
    @IBOutlet private weak var maxValueLabel : UILabel!
    @IBOutlet private weak var minValueLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func bind(to stepsByDay: [Date : Steps]) {
        let summary = stats(from: stepsByDay)
        displayAverage(summary.average)
        displayMinMax(summary.min, summary.max)
    }
    
    private func stats(from stepsByDay: [Date : Steps]) -> (average: Steps, min: Steps, max: Steps) {
        return (average: Steps(stepsByDay.values.mean()), min: stepsByDay.values.min() ?? 0, max: stepsByDay.values.max() ?? 0)
    }
    
    private func displayAverage(_ average: Steps) {
        let averageFormatted = Globals.stepsFormatter().string(for: average)!
        let averageAttributed = NSMutableAttributedString(string: String(format: NSLocalizedString("%@ daily average", comment: ""), averageFormatted), attributes: [.foregroundColor : Globals.averageColor()])
        
        if let numberRange = averageAttributed.string.range(of: averageFormatted) {
            averageAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 28.0, weight: .medium), range: NSRange(numberRange, in: averageAttributed.string))
        }
        
        averageLabel.attributedText = averageAttributed
    }
    
    private func displayMinMax(_ min: Steps, _ max: Steps) {
        minValueLabel.text = Globals.stepsFormatter().string(for: min)!
        maxValueLabel.text = Globals.stepsFormatter().string(for: max)!
    }
}
