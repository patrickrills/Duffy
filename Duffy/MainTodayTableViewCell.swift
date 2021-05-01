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
    
    @IBOutlet private weak var ringImage: UIImageView!
    @IBOutlet private weak var trophyLabel: UILabel!
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
        
        let trophy = Trophy.trophy(for: steps)
        
        var goalColor: UIColor
        var goalText: String
        
        if trophy == .none {
            trophyLabel.isHidden = true
            ringImage.isHidden = false
            ringImage.image = RingDrawer.drawRing(steps, goal: goalValue, width: ringImage.frame.size.width * UIScreen.main.scale)?.withRenderingMode(.alwaysTemplate)
            if #available(iOS 13.0, *) {
                goalColor = .label
            } else {
                goalColor = .black
            }
            goalText = NSLocalizedString("To go", comment: "")
        } else {
            ringImage.isHidden = true
            trophyLabel.isHidden = false
            trophyLabel.text = trophy.symbol()
            goalColor = Globals.successColor()
            goalText = String(format: "%@+", NSLocalizedString("Goal", comment: ""))
        }
        
        stepsLabel.text = formattedSteps
        goalLabel.text = String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedGoal, Trophy.none.symbol())
        toGoItemView.bind(title: goalText, value: formattedToGo, valueColor: goalColor, image: toGoImage(), symbol: trophy.symbol(), imageTintColor: Globals.lightGrayColor())
        flightsItemView.bind(title: NSLocalizedString("Flights", comment: ""), value: formattedFlights, image: UIImage(named: "Flights")!)
        
        let distanceTitle: String
        switch distanceUnit {
        case .kilometer:
            distanceTitle = NSLocalizedString("Kilometers", comment: "")
        case .mile:
            distanceTitle = NSLocalizedString("Miles", comment: "")
        default:
            distanceTitle = NSLocalizedString("Distance", comment: "")
        }
        
        distanceItemView.bind(title: distanceTitle, value: formattedDistance, image: UIImage(named: "Distance")!)
    }
    
    @IBAction private func goalInfoPressed() {
        if let root = UIApplication.shared.delegate?.window??.rootViewController {
            root.present(ModalNavigationController(rootViewController: GoalInstructionsTableViewController()), animated: true, completion: nil)
        }
    }
    
    private func toGoImage() -> UIImage {
        //TODO: send back small ring or trophy
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "speedometer", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18.0))!
        } else {
            return UIImage(named: "BigBlueFly")!
        }
    }
}
