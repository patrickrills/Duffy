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
    @IBOutlet private var oneInstructionsLabel: UILabel!
    @IBOutlet private var twoLabel: UILabel!
    @IBOutlet private var twoInstructionsLabel: UILabel!
    @IBOutlet private var threeLabel: UILabel!
    @IBOutlet private var threeInstructionsLabel: UILabel!
    @IBOutlet private var threeInstructionsImageView: UIImageView!
    @IBOutlet private var legendContainer: UIView!
    
    private var useLegacyInstructions: Bool {
        return Globals.watchSystemVersion() < 6.0
    }
    
    private let step3Insutructions = NSLocalizedString("Select a new goal by tapping the plus (+) or minus (-) buttons or turning the digital crown. Then tap the 'Set Goal' button to save it.", comment: "")
    private let step3InstructionsLegacy = NSLocalizedString("Select a new goal by swiping with your finger or turning the digital crown. Then tap the 'Set Goal' button to save it.", comment: "")
    
    init() {
        super.init(nibName: "GoalChangeHowToViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Change Your Goal", comment: "")
        
        self.headerLabel.text = String(format: NSLocalizedString("This guide describes how to change your daily steps goal (currently %@ steps). Your goal can only be changed from the Duffy Apple Watch app.", comment: ""), Globals.stepsFormatter().string(from: NSNumber(value: HealthCache.dailyGoal()))!)
        self.oneInstructionsLabel.text = NSLocalizedString("From the Today view of the Apple Watch app, force-touch (press slightly harder) anywhere on the screen.", comment: "")
        self.twoInstructionsLabel.text = NSLocalizedString("Tap 'Change Daily Goal' from the menu that appears.", comment: "")
        self.threeInstructionsLabel.text = useLegacyInstructions ? step3InstructionsLegacy : step3Insutructions
        self.threeInstructionsImageView.image = UIImage(named: (useLegacyInstructions ? "Instructions03-Legacy" : "Instructions03"))
        
        if let trophyView = TrophyLegendView.createView(showInstructionNumber: true) {
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
