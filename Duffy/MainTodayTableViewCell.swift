//
//  MainTodayTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 3/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class MainTodayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toGoItemView: MainTodayItemView!
    @IBOutlet weak var flightsItemView: MainTodayItemView!
    @IBOutlet weak var distanceItemView: MainTodayItemView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        toGoItemView.bind(title: "To Go", value: "0,000", systemImageName: "speedometer")
        flightsItemView.bind(title: "Flights", value: "00", systemImageName: "building.fill")
        distanceItemView.bind(title: "Miles", value: "00.0", systemImageName: "map.fill")
    }
    
}
