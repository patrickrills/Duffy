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
    
    private let numFormatter = NumberFormatter()
    private var stepCount = HealthCache.getStepsFromSharedCache(forDay: Date())
    
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
                DispatchQueue.main.async {
                    [weak self] in
                    self?.displaySteps()
                }
            }
        }, onFailure: nil)
    }
    
    private func displaySteps() {
        stepsValueLabel.text = numFormatter.string(from: NSNumber(value:stepCount))
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        stepCount = HealthCache.getStepsFromSharedCache(forDay: Date())
        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
            [weak self] steps, date in
            self?.stepCount = steps
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
