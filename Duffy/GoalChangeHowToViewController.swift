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
    }
}
