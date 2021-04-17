//
//  HourGraphDetailViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/15/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HourGraphDetailViewController: DetailDataViewPageViewController
{
    @IBOutlet weak var barsStackView : UIStackView?
    @IBOutlet weak var maxIndicator : HourGraphMaxIndicatorView?
    @IBOutlet weak var noStepsLabel : UILabel?
    @IBOutlet weak var sixAMLabel : UILabel?
    @IBOutlet weak var noonLabel : UILabel?
    @IBOutlet weak var sixPMLabel : UILabel?
    @IBOutlet weak var sixAMBottomConstraint : NSLayoutConstraint?
    @IBOutlet weak var noonBottomConstraint : NSLayoutConstraint?
    @IBOutlet weak var sixPMBottomConstraint : NSLayoutConstraint?
    
    override func refresh() {
        HealthKitService.getInstance().getStepsByHour(for: Date()) { [weak self] result in
            switch result {
            case .success(let steps):
                DispatchQueue.main.async {
                    self?.process(stepsByHour: steps.stepsByHour)
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func process(stepsByHour : [Hour : Steps]) {
        if let bars = barsStackView {
            var runningStepTotal: Steps = 0
            var reachedGoal = false
            var max: Steps = 0
            
            if stepsByHour.count > 0, let maxStepsInAnHour = stepsByHour.values.max() {
                max = maxStepsInAnHour
            }
            
            if (max > 0) {
                maxIndicator?.max = max
                maxIndicator?.isHidden = false
                noStepsLabel?.isHidden = true
            } else {
                maxIndicator?.isHidden = true
                noStepsLabel?.isHidden = false
            }
            
            for i in 0..<bars.arrangedSubviews.count {
                if let bar = bars.arrangedSubviews[i] as? HourGraphBarView {
                    var percent : CGFloat = 0.0
                    
                    if let steps = stepsByHour[Hour(i)] {
                        runningStepTotal += steps
                        
                        if max > 0 {
                            percent = CGFloat(CGFloat(steps) / CGFloat(max))
                        }
                    }
                    
                    bar.percent = percent
                    
                    if (runningStepTotal >= HealthCache.dailyGoal() && !reachedGoal) {
                        bar.color = Globals.successColor()
                        reachedGoal = true
                    } else {
                        bar.color = Globals.primaryColor()
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sixAMBottomConstraint?.constant = margin.bottom
        noonBottomConstraint?.constant = margin.bottom
        sixPMBottomConstraint?.constant = margin.bottom
        noStepsLabel?.textColor = Globals.lightGrayColor()
        
        if #available(iOS 13.0, *) {
            sixAMLabel?.textColor = .label
            noonLabel?.textColor = .label
            sixPMLabel?.textColor = .label
        }
    }
}
