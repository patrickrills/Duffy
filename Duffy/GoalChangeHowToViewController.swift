//
//  GoalChangeHowToViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/25/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit

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
        let cachedWatchVersion = Globals.watchSystemVersion()
        return cachedWatchVersion > 0.0 && cachedWatchVersion < 6.0
    }

    init() {
        super.init(nibName: "GoalChangeHowToViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = GoalInstructions.title()
        
        self.headerLabel.text = GoalInstructions.headline()
        self.oneInstructionsLabel.text = GoalInstructions.step1.text(useLegacyInstructions: useLegacyInstructions)
        self.twoInstructionsLabel.text = GoalInstructions.step2.text(useLegacyInstructions: useLegacyInstructions)
        self.threeInstructionsLabel.text = GoalInstructions.step3.text(useLegacyInstructions: useLegacyInstructions)
        
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
