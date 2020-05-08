//
//  GoalChangeHowToViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/25/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class GoalChangeHowToViewController: UIViewController {

    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var oneLabel: UILabel!
    @IBOutlet private var twoLabel: UILabel!
    @IBOutlet private var threeLabel: UILabel!
    @IBOutlet private var legendContainer: UIView!
    
    init() {
        super.init(nibName: "GoalChangeHowToViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Change Your Goal", comment: "")
        
        self.headerLabel.text = String(format: NSLocalizedString("This guide describes how to change your daily steps goal (currently %@ steps). Your goal can only be changed from the Duffy Apple Watch app.", comment: ""), Globals.stepsFormatter().string(from: NSNumber(value: HealthCache.getStepsDailyGoal()))!)
        
        if let trophyView = TrophyLegendView.createView() {
            self.legendContainer.addSubview(trophyView)
            NSLayoutConstraint.activate([
                trophyView.leadingAnchor.constraint(equalTo: self.legendContainer.leadingAnchor),
                trophyView.trailingAnchor.constraint(equalTo: self.legendContainer.trailingAnchor),
                trophyView.topAnchor.constraint(equalTo: self.legendContainer.topAnchor),
                self.legendContainer.bottomAnchor.constraint(equalTo: trophyView.bottomAnchor)
            ])
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
            self.headerLabel.textColor = .secondaryLabel
        } else {
            self.headerLabel.textColor = .darkGray
            view.backgroundColor = .white
        }
        
        self.oneLabel.textColor = Globals.primaryColor()
        self.twoLabel.textColor = self.oneLabel.textColor
        self.threeLabel.textColor = self.oneLabel.textColor
        
        if let trophyView = self.legendContainer.subviews.first as? TrophyLegendView {
            trophyView.fourLabel.textColor = self.oneLabel.textColor
        }
    }
}
