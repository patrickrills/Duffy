//
//  TodayHeaderView.swift
//  Duffy
//
//  Created by Patrick Rills on 6/23/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TodayHeaderView: UIView
{
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var subTitleLabel : UILabel?
    @IBOutlet weak var stepsValueLabel : UILabel?
    @IBOutlet weak var refreshButton : UIButton?
    @IBOutlet weak var goalLabel : UILabel?
    @IBOutlet weak var detailContainer : UIView?
    
    class func createView() -> TodayHeaderView?
    {
        if let nibViews = Bundle.main.loadNibNamed("TodayHeaderView", owner:nil, options:nil),
            let today = nibViews[0] as? TodayHeaderView
        {
            return today
        }
        
        return nil
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel?.textColor = Globals.primaryColor()
        subTitleLabel?.textColor = Globals.primaryColor()
        refreshButton?.setTitleColor(Globals.secondaryColor(), for: .normal)
        stepsValueLabel?.text = "0"
        updateGoalDisplay(stepsForDay: 0)
        
        if let container = detailContainer, let detail = DetailDataView.createView()
        {
            container.addSubview(detail)
            detail.translatesAutoresizingMaskIntoConstraints = false
            detail.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            detail.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            detail.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            detail.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
    }
    
    func toggleLoading(isLoading: Bool)
    {
        if let r = refreshButton
        {
            r.setTitle((isLoading ? "Loading..." : "STEPS"), for: .normal)
        }
    }
    
    func refresh()
    {
        HealthKitService.getInstance().getSteps(Date(), onRetrieve: {
            (stepsCount: Int, forDate: Date) in
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                if let weakSelf = self
                {
                    weakSelf.toggleLoading(isLoading: false)
                    weakSelf.stepsValueLabel?.text = Globals.stepsFormatter().string(from: NSNumber(value: stepsCount))
                    weakSelf.updateGoalDisplay(stepsForDay: stepsCount)
                }
            })
        }, onFailure: {
            [weak self] (error: Error?) in
            self?.toggleLoading(isLoading: false)
        })
        
        HealthKitService.getInstance().getStepsByHour(forDate: Date(),
                                                      onRetrieve: {
                                                        stepsByHour, queryDate in
                                                        
                                                        if (stepsByHour.count == 0)
                                                        {
                                                            print("No steps by hour")
                                                        }
                                                        else
                                                        {
                                                            for hour in stepsByHour.keys.sorted()
                                                            {
                                                                if let steps = stepsByHour[hour]
                                                                {
                                                                    print("Retrieved \(steps) steps in hour: \(hour)")
                                                                }
                                                            }
                                                        }
        },
                                                      onFailure: {
                                                        error in
                                                        
                                                        if let e = error
                                                        {
                                                            print("Got an error: \(e)")
                                                        }
        })
        
        if let container = detailContainer, container.subviews.count > 0, let details = container.subviews[0] as? DetailDataView
        {
            details.refresh()
        }
    }
    
    private func updateGoalDisplay(stepsForDay: Int)
    {
        if let lbl = goalLabel
        {
            let goalValue = HealthCache.getStepsDailyGoal()
            if goalValue > 0, let formattedValue = Globals.stepsFormatter().string(from: NSNumber(value: goalValue))
            {
                lbl.text = String(format: "of %@ goal %@", formattedValue, HealthKitService.getInstance().getAdornment(for: stepsForDay))
            }
            else
            {
                lbl.text = nil
            }
        }
    }
    
    @IBAction func refreshPressed()
    {
        toggleLoading(isLoading: true)
        refresh()
    }
}
