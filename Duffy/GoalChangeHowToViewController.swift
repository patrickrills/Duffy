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

        self.title = "Change Your Goal"
        self.headerLabel.textColor = .darkGray
        self.headerLabel.text = String(format: "This guide describes how to change your daily steps goal (currently %@ steps). Your goal can only be changed from the Duffy Apple Watch app.", Globals.stepsFormatter().string(from: NSNumber(value: HealthCache.getStepsDailyGoal()))!)
        self.oneLabel.textColor = Globals.primaryColor()
        self.twoLabel.textColor = self.oneLabel.textColor
        self.threeLabel.textColor = self.oneLabel.textColor
    }
}
