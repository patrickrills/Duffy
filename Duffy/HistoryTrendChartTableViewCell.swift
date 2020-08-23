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
    @IBOutlet weak var chart : HistoryTrendChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func bind(to stepsByDay: [Date : Steps]) {
        chart.dataSet = stepsByDay
    }
}
