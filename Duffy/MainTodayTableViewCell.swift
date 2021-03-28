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
    
    @IBOutlet private weak var ringContainer: UIImageView!
    @IBOutlet private weak var stepsLabel: UILabel!
    @IBOutlet private weak var goalLabel: UILabel!
    @IBOutlet private weak var goalInfoButton: UIButton!
    @IBOutlet private weak var toGoItemView: MainTodayItemView!
    @IBOutlet private weak var flightsItemView: MainTodayItemView!
    @IBOutlet private weak var distanceItemView: MainTodayItemView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        goalLabel.isUserInteractionEnabled = true
        goalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goalInfoPressed)))
        goalInfoButton.tintColor = Globals.secondaryColor()
        if #available(iOS 13.0, *) {
            goalLabel.textColor = .secondaryLabel
            goalInfoButton.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        } else {
            goalLabel.textColor = Globals.lightGrayColor()
        }
        
        bind(steps: 0, flights: 0, distance: 0, distanceUnit: .mile)
    }
    
    func bind(steps: Steps, flights: FlightsClimbed, distance: DistanceTravelled, distanceUnit: LengthFormatter.Unit) {
        
        //TODO: What is the loading state?
        
        guard case let goalValue = HealthCache.dailyGoal(),
            goalValue > 0,
            let formattedGoal = Globals.stepsFormatter().string(for: goalValue),
            let formattedToGo = Globals.stepsFormatter().string(for: abs(Int32(goalValue) - Int32(steps))),
            let formattedSteps = Globals.stepsFormatter().string(for: steps),
            let formattedFlights = Globals.flightsFormatter().string(for: flights),
            let formattedDistance = Globals.distanceFormatter().string(for: distance)
        else {
            goalLabel.text = nil
            return
        }
        
        ringContainer.image = RingDrawer.drawRing(steps, goal: goalValue, width: ringContainer.frame.size.width * UIScreen.main.scale)?.withRenderingMode(.alwaysTemplate)
        stepsLabel.text = formattedSteps
        goalLabel.text = String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedGoal, Trophy.trophy(for: steps).symbol())
        toGoItemView.bind(title: "To Go", value: formattedToGo, systemImageName: "speedometer")
        flightsItemView.bind(title: "Flights", value: formattedFlights, systemImageName: "building.fill")
        
        //TODO: Miles or Kilometers - add to string dict
        distanceItemView.bind(title: "Miles", value: formattedDistance, systemImageName: "map.fill")
    }
    
    @IBAction private func goalInfoPressed() {
        if let root = UIApplication.shared.delegate?.window??.rootViewController {
            root.present(ModalNavigationController(rootViewController: GoalInstructionsTableViewController()), animated: true, completion: nil)
        }
    }
}
