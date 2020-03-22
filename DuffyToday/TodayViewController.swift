//
//  TodayViewController.swift
//  DuffyToday
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import NotificationCenter
import DuffyFramework

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var stepsValueLabel : UILabel!
    @IBOutlet weak var flightsValueLabel : UILabel!
    @IBOutlet weak var distanceValueLabel : UILabel!
    @IBOutlet weak var distanceUnitsLabel : UILabel!
    @IBOutlet weak var progressRingView: ProgressRingView!
    
    private let numFormatter = NumberFormatter()
    private var stepCount = 0
    private var dailyGoal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numFormatter.numberStyle = .decimal
        numFormatter.locale = Locale.current
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displaySteps()
        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
            [weak self] steps, date in
            if let weakSelf = self {
                weakSelf.stepCount = steps
                weakSelf.dailyGoal = HealthCache.getStepsDailyGoalFromShared()
                DispatchQueue.main.async {
                    [weak self] in
                    self?.displaySteps()
                }
            }
        }, onFailure: nil)
        
        HealthKitService.getInstance().getFlightsClimbed(Date(), onRetrieve: {
            [weak self] flights, date in
            DispatchQueue.main.async {
                self?.flightsValueLabel.text = self?.numFormatter.string(for: flights)
            }
        }, onFailure: nil)
        
        HealthKitService.getInstance().getDistanceCovered(Date(), onRetrieve: {
            [weak self] distance, units, date in
            let unitsFormatted = units == .mile ? NSLocalizedString("miles", comment: "") : NSLocalizedString("kilometers", comment: "")
            if let valueFormatted = self?.numFormatter.string(from: NSNumber(value: distance)) {
                DispatchQueue.main.async {
                    self?.distanceValueLabel.text = valueFormatted
                    self?.distanceUnitsLabel.text = unitsFormatted
                }
            }
            
        }, onFailure: nil)
    }
    
    private func displaySteps() {
        stepsValueLabel.text = numFormatter.string(from: NSNumber(value:stepCount))
        if dailyGoal > 0 {
            progressRingView.isHidden = false
            progressRingView.progress = CGFloat(stepCount) / CGFloat(dailyGoal)
        } else {
            progressRingView.isHidden = true
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
            [weak self] steps, date in
            self?.stepCount = steps
            self?.dailyGoal = HealthCache.getStepsDailyGoalFromShared()
            completionHandler(NCUpdateResult.newData)
            }, onFailure: {
                error in
                completionHandler(NCUpdateResult.failed)
        })
    }
    
    @IBAction private func launchParentApp() {
        UIApplication.shared.open(URL(string: "duffy://")!, options: [:], completionHandler: nil)
    }
}
