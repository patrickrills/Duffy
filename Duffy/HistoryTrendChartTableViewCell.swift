//
//  HistoryTrendChartTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 11/18/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTrendChartTableViewCell: UITableViewCell
{
    @IBOutlet weak var averageLabel : UILabel?
    @IBOutlet weak var chart : HistoryTrendChartView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(toStepsByDay: [Date : Int]) {
        var average : Int = 0
        
        if toStepsByDay.count > 0 {
            average = toStepsByDay.values.reduce(0, +) / toStepsByDay.count
        }
        
        let averageFormatted = Globals.stepsFormatter().string(from: NSNumber(value: average))!
        let averageAttributed = NSMutableAttributedString(string: String(format: NSLocalizedString("%@ daily average", comment: ""), averageFormatted))
        
        if let numberRange = averageAttributed.string.range(of: averageFormatted) {
            averageAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 24.0, weight: .medium), range: NSRange(numberRange, in: averageAttributed.string))
        }
        
        averageLabel?.attributedText = averageAttributed
        chart?.dataSet = toStepsByDay
    }
}
