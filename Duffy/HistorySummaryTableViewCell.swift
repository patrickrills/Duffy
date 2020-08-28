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
    @IBOutlet private weak var maxDateLabel : UILabel!
    @IBOutlet private weak var minDateLabel : UILabel!
    @IBOutlet private weak var averageBar : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        averageBar.clipsToBounds = true
        if #available(iOS 13.0, *) {
            averageBar.backgroundColor = .systemGray4
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        averageBar.layer.cornerRadius = averageBar.frame.size.height / 2.0
    }

    func bind(to stepsByDay: [Date : Steps]) {
        let summary = stats(from: stepsByDay)
        displayAverage(summary.average)
        displayExtreme(summary.min, minValueLabel, minDateLabel)
        displayExtreme(summary.max, maxValueLabel, maxDateLabel)
    }
    
    typealias Extreme = (key: Date, value: Steps)
    typealias Stats = (average: Steps, min: Extreme?, max: Extreme?)
    
    private func stats(from stepsByDay: [Date : Steps]) -> Stats {
        return Stats(average: Steps(stepsByDay.values.mean()),
                     min: stepsByDay.min(by: { $0.value < $1.value }),
                     max: stepsByDay.max(by: { $0.value < $1.value }))
    }
    
    private func displayAverage(_ average: Steps) {
        let averageFormatted = Globals.stepsFormatter().string(for: average)!
        let averageAttributed = NSMutableAttributedString(string: String(format: NSLocalizedString("%@ daily average", comment: ""), averageFormatted), attributes: [.foregroundColor : Globals.averageColor()])
        
        if let numberRange = averageAttributed.string.range(of: averageFormatted) {
            averageAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 28.0, weight: .medium), range: NSRange(numberRange, in: averageAttributed.string))
        }
        
        averageLabel.attributedText = averageAttributed
        
        //TODO: Place dot on average bar
    }
    
    private func displayExtreme(_ x: Extreme?, _ valueLabel: UILabel, _ dateLabel: UILabel) {
        if let x = x {
            valueLabel.text = Globals.stepsFormatter().string(for: x.value)!
            dateLabel.text = Globals.dayFormatter().string(from: x.key)
        } else {
            valueLabel.text = nil
            dateLabel.text = nil
        }
    }
}
