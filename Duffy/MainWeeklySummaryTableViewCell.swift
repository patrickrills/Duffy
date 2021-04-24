//
//  MainWeeklySummaryTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 4/18/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class MainWeeklySummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var averageLabel : UILabel!
    @IBOutlet weak var progressLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func bind(average: Steps, progress: Double) {
        averageLabel.text = Globals.stepsFormatter().string(for: average)
        averageLabel.textColor = Globals.averageColor()
        
        progressLabel.text = Globals.percentFormatter().string(for: progress)
    }
}
