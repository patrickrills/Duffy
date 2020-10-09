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
    @IBOutlet weak var stepsValueLabel : UILabel!
    @IBOutlet weak var refreshButton : UIButton!
    @IBOutlet weak var goalLabel : UILabel!
    @IBOutlet weak var goalInfoButton : UIButton!
    @IBOutlet weak var detailContainer : UIView!
    @IBOutlet weak var topMargin : NSLayoutConstraint!
    @IBOutlet weak var chartMargin : NSLayoutConstraint!
    @IBOutlet weak var bottomMargin : NSLayoutConstraint!
    
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
        
        stepsValueLabel.text = "0"
        updateGoalDisplay(stepsForDay: 0)
        
        if let detail = DetailDataView.createView()
        {
            detailContainer.addSubview(detail)
            detail.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                detail.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor),
                detail.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor),
                detail.topAnchor.constraint(equalTo: detailContainer.topAnchor),
                detail.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor)
            ])
        }
        
        if Globals.isMaxPhone() {
            topMargin.constant = 56.0
            bottomMargin.constant = 42.0
        } else if Globals.isTallPhone() {
            topMargin.constant = 40.0
            bottomMargin.constant = 28.0
        } else {
            topMargin.constant = 24.0
            bottomMargin.constant = 8.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshButton.setTitleColor(Globals.secondaryColor(), for: .normal)
        goalInfoButton.tintColor = Globals.secondaryColor()
        
        if #available(iOS 13.0, *) {
            stepsValueLabel.textColor = .label
            goalLabel.textColor = .label
        }
    }
    
    func toggleLoading(isLoading: Bool) {
        refreshButton.setTitle((isLoading ? NSLocalizedString("Loading...", comment: "") : NSLocalizedString("STEPS", comment: "")), for: .normal)
    }
    
    func refresh() {
        HealthKitService.getInstance().getSteps(for: Date()) { [weak self] result in
            switch result {
            case .success(let stepsResult):
                DispatchQueue.main.async {
                    guard let weakSelf = self else { return }
                    weakSelf.toggleLoading(isLoading: false)
                    weakSelf.stepsValueLabel.text = Globals.stepsFormatter().string(for: stepsResult.steps)
                    weakSelf.updateGoalDisplay(stepsForDay: stepsResult.steps)
                }
            case .failure(_):
                self?.toggleLoading(isLoading: false)
            }
        }
        
        if detailContainer.subviews.count > 0, let details = detailContainer.subviews[0] as? DetailDataView {
            details.refresh()
        }
    }
    
    private func updateGoalDisplay(stepsForDay: Steps) {
        guard case let goalValue = HealthCache.dailyGoal(),
            goalValue > 0,
            let formattedValue = Globals.stepsFormatter().string(for: goalValue)
        else {
            goalLabel.text = nil
            return
        }
        
        goalLabel.text = String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedValue, Trophy.trophy(for: stepsForDay).symbol())
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
