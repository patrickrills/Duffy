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
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var subTitleLabel : UILabel!
    @IBOutlet weak var stepsValueLabel : UILabel!
    @IBOutlet weak var refreshButton : UIButton!
    @IBOutlet weak var goalLabel : UILabel!
    @IBOutlet weak var goalInfoButton : UIButton!
    @IBOutlet weak var detailContainer : UIView!
    
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
        
        titleLabel.textColor = Globals.primaryColor()
        subTitleLabel.textColor = Globals.primaryColor()
        refreshButton.setTitleColor(Globals.secondaryColor(), for: .normal)
        goalInfoButton.tintColor = Globals.secondaryColor()
        stepsValueLabel.text = "0"
        updateGoalDisplay(stepsForDay: 0)
        
        if let detail = DetailDataView.createView()
        {
            detailContainer.addSubview(detail)
            detail.translatesAutoresizingMaskIntoConstraints = false
            detail.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor).isActive = true
            detail.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor).isActive = true
            detail.topAnchor.constraint(equalTo: detailContainer.topAnchor).isActive = true
            detail.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor).isActive = true
        }
    }
    
    func toggleLoading(isLoading: Bool)
    {
        refreshButton.setTitle((isLoading ? "Loading..." : "STEPS"), for: .normal)
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
                    weakSelf.stepsValueLabel.text = Globals.stepsFormatter().string(from: NSNumber(value: stepsCount))
                    weakSelf.updateGoalDisplay(stepsForDay: stepsCount)
                }
            })
        }, onFailure: {
            [weak self] (error: Error?) in
            self?.toggleLoading(isLoading: false)
        })
        
        if detailContainer.subviews.count > 0, let details = detailContainer.subviews[0] as? DetailDataView
        {
            details.refresh()
        }
    }
    
    private func updateGoalDisplay(stepsForDay: Int)
    {
        let goalValue = HealthCache.getStepsDailyGoal()
        if goalValue > 0, let formattedValue = Globals.stepsFormatter().string(from: NSNumber(value: goalValue))
        {
            goalLabel.text = String(format: "of %@ goal %@", formattedValue, HealthKitService.getInstance().getAdornment(for: stepsForDay))
        }
        else
        {
            goalLabel.text = nil
        }
    }
    
    @IBAction func refreshPressed()
    {
        toggleLoading(isLoading: true)
        refresh()
    }
    
    @IBAction func goalInfoPressed() {
        if let root = UIApplication.shared.delegate?.window??.rootViewController {
            root.present(ModalNavigationController(rootViewController: GoalChangeHowToViewController()), animated: true, completion: nil)
        }
    }
}
