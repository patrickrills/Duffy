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
    private var stepCount: Int = 0
    private var dailyGoal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numFormatter.numberStyle = .decimal
        numFormatter.locale = Locale.current
        numFormatter.maximumFractionDigits = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stepCount = getCachedValue()
        
        displaySteps()
        
        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
            [weak self] steps, date in
            if let weakSelf = self {
                weakSelf.stepCount = steps
                weakSelf.dailyGoal = HealthCache.getStepsDailyGoalFromShared()
                let _ = HealthCache.saveStepsToCache(steps, forDay: date)
                DispatchQueue.main.async {
                    [weak self] in
                    self?.displaySteps()
                }
            }
        }, onFailure: nil)
        
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
        if #available(iOS 13.0, *) {
            distanceIcon.tintColor = .label
            distanceValueLabel.textColor = .label
            flightsIcon.tintColor = .label
            flightsValueLabel.textColor = .label
        } else {
            distanceIcon.tintColor = .black
            flightsIcon.tintColor = .black
        }
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
    
    private func getCachedValue() -> Int {
        guard !HealthCache.cacheIsForADifferentDay(Date()) else {
            return 0
        }
        
        return HealthCache.getStepsFromCache(Date())
    }
    
    @IBAction private func launchParentApp() {
        UIApplication.shared.open(URL(string: "duffy://")!, options: [:], completionHandler: nil)
    }
}
