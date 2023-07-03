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

    @IBOutlet private weak var averageTitleLabel : UILabel!
    @IBOutlet private weak var averageLabel : UILabel!
    @IBOutlet private weak var totalLabel : UILabel!
    @IBOutlet private weak var maxValueLabel : UILabel!
    @IBOutlet private weak var minValueLabel : UILabel!
    @IBOutlet private weak var maxDateLabel : UILabel!
    @IBOutlet private weak var minDateLabel : UILabel!
    @IBOutlet private weak var averageBar : UIView!
    @IBOutlet private weak var averageDot : UIView!
    @IBOutlet private weak var averageBarHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var averageDotHeightConstraint : NSLayoutConstraint!
    @IBOutlet private weak var averageDotPaddingConstraint : NSLayoutConstraint!
    @IBOutlet private weak var averageDotLeadingConstraint : NSLayoutConstraint!
    @IBOutlet private weak var overLabel : UILabel!
    
    private var averagePositionPercent: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isUserInteractionEnabled = false
        
        averageBar.layer.cornerRadius = averageBarHeightConstraint.constant / 2.0
        averageDot.layer.cornerRadius = averageDotHeightConstraint.constant / 2.0
        averageDot.subviews.forEach({ $0.layer.cornerRadius = (averageDotHeightConstraint.constant - (averageDotPaddingConstraint.constant * 2.0)) / 2.0 })
        averageDot.isHidden = true
        
        maxValueLabel.textColor = .label
        minValueLabel.textColor = .label
        maxDateLabel.textColor = .secondaryLabel
        minDateLabel.textColor = .secondaryLabel
        averageBar.backgroundColor = .systemGray4
        averageDot.backgroundColor = .secondarySystemGroupedBackground
    }

    func bind(to stepsByDay: [Date : Steps]) {
        let summary = stats(from: stepsByDay)
        displayAverage(summary.average)
        displayTotal(summary.total)
        displayExtreme(summary.min, minValueLabel, minDateLabel)
        displayExtreme(summary.max, maxValueLabel, maxDateLabel)
        calculateDotPosition(summary)
        displayOverCount(summary.overDaysCount, since: stepsByDay.keys.min() ?? Date().previousDay())
        setNeedsLayout()
    }
    
    typealias Extreme = (key: Date, value: Steps)
    typealias Stats = (average: Steps, total: Steps, min: Extreme?, max: Extreme?, overDaysCount: UInt)
    
    private func stats(from stepsByDay: [Date : Steps]) -> Stats {
        let goal = HealthCache.dailyGoal()
        return Stats(average: Steps(stepsByDay.values.mean()),
                     total: Steps(stepsByDay.values.sum()),
                     min: stepsByDay.count > 1 ? stepsByDay.min(by: { $0.value < $1.value }) : nil,
                     max: stepsByDay.count > 1 ? stepsByDay.max(by: { $0.value < $1.value }) : nil,
                     overDaysCount: UInt(stepsByDay.values.filter({ $0 >= goal }).count))
    }
    
    private func displayAverage(_ average: Steps) {
        averageTitleLabel.text = NSLocalizedString("Daily Average", comment: "")
        averageTitleLabel.textColor = .secondaryLabel
        
        let averageFormatted = Globals.stepsFormatter().string(for: average)!
        averageLabel.text = averageFormatted
        averageLabel.textColor = Globals.averageColor()
    }
    
    private func displayTotal(_ total: Steps) {
        let totalFormatted = Globals.stepsFormatter().string(for: total)!
        totalLabel.text = String(format: NSLocalizedString("%@ total", comment: ""), totalFormatted)
        totalLabel.textColor = .secondaryLabel
    }
    
    private func displayExtreme(_ x: Extreme?, _ valueLabel: UILabel, _ dateLabel: UILabel) {
        if let x = x {
            valueLabel.text = Globals.stepsFormatter().string(for: x.value)!
            dateLabel.text = Globals.shortDateFormatter().string(from: x.key).uppercased()
        } else {
            valueLabel.text = nil
            dateLabel.text = nil
        }
    }
    
    private func calculateDotPosition(_ stats: Stats) {
        guard let min = stats.min,
            let max = stats.max,
            stats.average > 0
        else {
            averagePositionPercent = nil
            return
        }
        
        let span = max.value - min.value
        averagePositionPercent = Double(stats.average - min.value) / Double(span)
    }
    
    private func displayOverCount(_ overCount: UInt, since startDate: Date) {
        let numberOfDays = startDate.differenceInDays(from: Date())
        let percentOfDays = Double(overCount) / Double(numberOfDays)
        
        let countString = NSLocalizedString("summary_goal_count", comment: "")
        let formatted = String.localizedStringWithFormat(countString, overCount, Globals.stepsFormatter().string(for: numberOfDays)!, Globals.percentFormatter().string(for: percentOfDays)!)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: formatted))
        attributedText.addAttribute(.foregroundColor, value: UIColor.label.withAlphaComponent(0.7), range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: attributedText.length))
        
        overLabel.attributedText = attributedText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded() //Required so averageBar width is final

        if let averagePositionPercent = averagePositionPercent,
           averagePositionPercent > 0.0
        {
            let barWidth = averageBar.frame.size.width
            let rawPosition = barWidth * CGFloat(averagePositionPercent)
            averageDot.isHidden = false
            averageDotLeadingConstraint.constant = rawPosition - (averageBarHeightConstraint.constant / 2.0)
        } else {
            averageDot.isHidden = true
        }
    }

}
