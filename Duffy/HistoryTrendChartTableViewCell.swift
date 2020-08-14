//
//  HistoryTrendChartTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 11/18/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistoryTrendChartTableViewCell: UITableViewCell
{
    @IBOutlet weak var averageLabel : UILabel!
    @IBOutlet weak var chart : HistoryTrendChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(to stepsByDay: [Date : Int]) {
        let average = Int(stepsByDay.values.mean())
        let averageFormatted = Globals.stepsFormatter().string(from: NSNumber(value: average))!
        let averageAttributed = NSMutableAttributedString(string: String(format: NSLocalizedString("%@ daily average", comment: ""), averageFormatted))
        
        if let numberRange = averageAttributed.string.range(of: averageFormatted) {
            averageAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 24.0, weight: .medium), range: NSRange(numberRange, in: averageAttributed.string))
        }
        
        if DebugService.isDebugModeEnabled() {
            averageAttributed.addAttribute(.foregroundColor, value: Globals.averageColor(), range: NSRange(location: 0, length: averageAttributed.string.count))
        }
        
        averageLabel.attributedText = averageAttributed
        chart.dataSet = stepsByDay
    }
}
