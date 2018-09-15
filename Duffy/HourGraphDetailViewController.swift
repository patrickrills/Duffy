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
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint?
    @IBOutlet weak var maxLabel : UILabel?
    
    override func refresh()
    {
        HealthKitService.getInstance().getStepsByHour(forDate: Date(),
            onRetrieve: {
                [weak self] stepsByHour, queryDate in
                
                DispatchQueue.main.async {
                    self?.process(stepsByHour: stepsByHour)
                }
            },
            onFailure: nil
        )
    }
    
    private func process(stepsByHour : [UInt : Int])
    {
        if let bars = barsStackView
        {
            var runningStepTotal : Int = 0
            var max : Int = 0
            
            if let maxStepsInAnHour = stepsByHour.values.max()
            {
                max = maxStepsInAnHour
            }
            
            if (max > 0)
            {
                maxLabel?.text = Globals.stepsFormatter().string(from: NSNumber(value: max))
                maxLabel?.isHidden = false
            }
            else
            {
                maxLabel?.isHidden = true
            }
            
            for i in 0..<bars.arrangedSubviews.count
            {
                if let bar = bars.arrangedSubviews[i] as? HourGraphBarView
                {
                    var percent : CGFloat = 0.0
                    
                    if let steps = stepsByHour[UInt(i)]
                    {
                        runningStepTotal += steps
                        
                        if max > 0
                        {
                            percent = CGFloat(CGFloat(steps) / CGFloat(max))
                        }
                    }
                    
                    bar.percent = percent
                    
                    if (runningStepTotal >= HealthCache.getStepsDailyGoal())
                    {
                        bar.color = Globals.successColor()
                    }
                    else
                    {
                        bar.color = Globals.primaryColor()
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        bottomConstraint?.constant = margin.bottom
    }
}
