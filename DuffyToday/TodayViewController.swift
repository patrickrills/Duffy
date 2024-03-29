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
    @IBOutlet weak var stepsDescriptionLabel : UILabel!
    @IBOutlet weak var flightsValueLabel : UILabel!
    @IBOutlet weak var flightsIcon : UIImageView!
    @IBOutlet weak var distanceValueLabel : UILabel!
    @IBOutlet weak var distanceIcon : UIImageView!
    @IBOutlet weak var progressRingView: ProgressRingView!
    
    private let numFormatter = NumberFormatter()
    private var stepCount: Steps = 0
    private var dailyGoal: Steps = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numFormatter.numberStyle = .decimal
        numFormatter.locale = Locale.current
        numFormatter.maximumFractionDigits = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stepCount = Steps(getCachedValue())
        
        displaySteps()
        
        HealthKitService.getInstance().getSteps(for: Date()) { [weak self] result in
            switch result {
            case .success(let stepsResult):
                if let weakSelf = self {
                    weakSelf.stepCount = stepsResult.steps
                    weakSelf.dailyGoal = HealthCache.dailyGoal()
                    HealthCache.saveStepsToCache(stepsResult.steps, for: stepsResult.day)
                    DispatchQueue.main.async {
                        self?.displaySteps()
                    }
                }
            case .failure(let error):
                LoggingService.log(error: error)
            }
        }
        
        HealthKitService.getInstance().getFlightsClimbed(for: Date()) { [weak self] result in
            switch result {
            case .success(let flightsResult):
                if let valueFormatted = self?.numFormatter.string(for: flightsResult.flights) {
                    let flightsLocalized = NSLocalizedString("floors", comment: "")
                    let flightsAttributed = NSMutableAttributedString(string: String(format: "%@ %@", valueFormatted, flightsLocalized))
                    flightsAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0), range: NSRange(location: flightsAttributed.string.count - flightsLocalized.count, length: flightsLocalized.count))
                    DispatchQueue.main.async {
                        self?.flightsValueLabel.attributedText = flightsAttributed
                    }
                }
            case .failure(let error):
                LoggingService.log(error: error)
            }
        }
        
        HealthKitService.getInstance().getDistanceCovered(for: Date()) { [weak self] result in
            switch result {
            case .success(let distanceResult):
                let unitsFormatted = distanceResult.formatter == .mile ? NSLocalizedString("mi", comment: "") : NSLocalizedString("km", comment: "")
                
                if let valueFormatted = self?.numFormatter.string(for: distanceResult.distance) {
                    let distanceAttributed = NSMutableAttributedString(string: String(format: "%@ %@", valueFormatted, unitsFormatted))
                    distanceAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0), range: NSRange(location: distanceAttributed.string.count - unitsFormatted.count, length: unitsFormatted.count))
                    DispatchQueue.main.async {
                        self?.distanceValueLabel.attributedText = distanceAttributed
                    }
                }
            case .failure(let error):
                LoggingService.log(error: error)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        distanceIcon.tintColor = .label
        distanceValueLabel.textColor = .label
        flightsIcon.tintColor = .label
        flightsValueLabel.textColor = .label
    }
    
    private func displaySteps() {
        stepsValueLabel.text = numFormatter.string(for: stepCount)
        if dailyGoal > 0 {
            progressRingView.isHidden = false
            progressRingView.progress = CGFloat(stepCount) / CGFloat(dailyGoal)
            
            let adornment = Trophy.trophy(for: stepCount).symbol()
            let localizedStepsDescription = NSLocalizedString("STEPS", comment: "")
            if adornment.count > 0 {
                stepsDescriptionLabel.text = String(format: "%@%@", localizedStepsDescription, adornment)
            } else {
                stepsDescriptionLabel.text = localizedStepsDescription
            }
        } else {
            progressRingView.isHidden = true
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        HealthKitService.getInstance().getSteps(for: Date()) { [weak self] result in
            switch result {
            case .success(let stepsResult):
                self?.stepCount = stepsResult.steps
                self?.dailyGoal = HealthCache.dailyGoal()
                completionHandler(.newData)
            case .failure(_):
                completionHandler(.failed)
            }
        }
    }
    
    private func getCachedValue() -> Steps {
        return HealthCache.lastSteps(for: Date())
    }
    
    @IBAction private func launchParentApp() {
        extensionContext?.open(URL(string: "duffy://")!, completionHandler: nil)
    }
}
