//
//  MainTodayTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 3/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class MainTodayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalInfoButton: UIButton!
    @IBOutlet weak var toGoItemView: MainTodayItemView!
    @IBOutlet weak var flightsItemView: MainTodayItemView!
    @IBOutlet weak var distanceItemView: MainTodayItemView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        toGoItemView.bind(title: "To Go", value: "0", systemImageName: "speedometer")
        flightsItemView.bind(title: "Flights", value: "0", systemImageName: "building.fill")
        distanceItemView.bind(title: "Miles", value: "0", systemImageName: "map.fill")
        updateGoalDisplay(stepsForDay: 0)
        
        goalLabel.isUserInteractionEnabled = true
        goalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalInfoPressed)))
        goalInfoButton.tintColor = Globals.secondaryColor()
        if #available(iOS 13.0, *) {
            goalLabel.textColor = .secondaryLabel
            goalInfoButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        } else {
            goalLabel.textColor = Globals.lightGrayColor()
        }
    }
    
    private func updateGoalDisplay(stepsForDay: Steps) {
        guard case let goalValue = HealthCache.dailyGoal(),
            goalValue > 0,
            let formattedGoal = Globals.stepsFormatter().string(for: goalValue),
            let formattedToGo = Globals.stepsFormatter().string(for: (goalValue - stepsForDay))
        else {
            goalLabel.text = nil
            return
        }
        
        goalLabel.text = String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedGoal, Trophy.trophy(for: stepsForDay).symbol())
        toGoItemView.bind(title: "To Go", value: formattedToGo, systemImageName: "speedometer")
    }
    
    @IBAction private func goalInfoPressed() {
        if let root = UIApplication.shared.delegate?.window??.rootViewController {
            root.present(ModalNavigationController(rootViewController: GoalInstructionsTableViewController()), animated: true, completion: nil)
        }
    }
}
