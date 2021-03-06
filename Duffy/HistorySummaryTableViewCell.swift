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
        
        if #available(iOS 13.0, *) {
            maxValueLabel.textColor = .label
            minValueLabel.textColor = .label
            maxDateLabel.textColor = .secondaryLabel
            minDateLabel.textColor = .secondaryLabel
            averageBar.backgroundColor = .systemGray4
            averageDot.backgroundColor = .secondarySystemGroupedBackground
        } else {
            maxValueLabel.textColor = .black
            minValueLabel.textColor = .black
            maxDateLabel.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            minDateLabel?.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
            averageDot.backgroundColor = .white
        }
    }

    func bind(to stepsByDay: [Date : Steps]) {
        let summary = stats(from: stepsByDay)
        displayAverage(summary.average)
        displayExtreme(summary.min, minValueLabel, minDateLabel)
        displayExtreme(summary.max, maxValueLabel, maxDateLabel)
        calculateDotPosition(summary)
        displayOverCount(summary.overDaysCount, since: stepsByDay.keys.min() ?? Date().previousDay())
        setNeedsLayout()
    }
    
    typealias Extreme = (key: Date, value: Steps)
    typealias Stats = (average: Steps, min: Extreme?, max: Extreme?, overDaysCount: UInt)
    
    private func stats(from stepsByDay: [Date : Steps]) -> Stats {
        let goal = HealthCache.dailyGoal()
        return Stats(average: Steps(stepsByDay.values.mean()),
                     min: stepsByDay.count > 1 ? stepsByDay.min(by: { $0.value < $1.value }) : nil,
                     max: stepsByDay.count > 1 ? stepsByDay.max(by: { $0.value < $1.value }) : nil,
                     overDaysCount: UInt(stepsByDay.values.filter({ $0 >= goal }).count))
    }
    
    private func displayAverage(_ average: Steps) {
        let averageFormatted = Globals.stepsFormatter().string(for: average)!
        let averageAttributed = NSMutableAttributedString(string: String(format: NSLocalizedString("%@ daily average", comment: ""), averageFormatted), attributes: [.foregroundColor : Globals.averageColor()])
        
        if let numberRange = averageAttributed.string.range(of: averageFormatted) {
            averageAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 28.0, weight: .medium), range: NSRange(numberRange, in: averageAttributed.string))
        }
        
        averageLabel.attributedText = averageAttributed
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
        var textColor: UIColor = .systemGray
        
        if #available(iOS 13.0, *) {
            textColor = UIColor.label.withAlphaComponent(0.7)
        }
        
        attributedText.append(NSAttributedString(string: formatted))
        attributedText.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedText.length))
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
