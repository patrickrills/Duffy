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
        
        HealthKitService.getInstance().getFlightsClimbed(Date(), onRetrieve: {
            flights, forDate in
            print("Number of flights climbed is \(flights)")
            
        }, onFailure: {
            (error: Error?) in
            print("error getting flights: \(String(describing: error))")
        })
        
        HealthKitService.getInstance().getDistanceCovered(Date(), onRetrieve: {
            distance, lengthUnit, forDate in

            let formatter = LengthFormatter()
            let displayDistance = formatter.string(fromValue: distance, unit: lengthUnit)
            print("Distance is \(displayDistance)")

        }, onFailure: {
            (error: Error?) in
            print("error getting flights: \(String(describing: error))")
        })
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