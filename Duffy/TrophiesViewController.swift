//
//  TrophiesUIViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 5/11/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit

class TrophiesViewController: UIViewController {
    
    @IBOutlet private weak var legendContainer: UIView!
    
    init() {
        super.init(nibName: "TrophiesViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Trophies"
        
        if let legend = TrophyLegendView.createView(showInstructionNumber: false) {
            legendContainer.addSubview(legend)
            NSLayoutConstraint.activate([
                legend.topAnchor.constraint(equalTo: legendContainer.topAnchor),
                legend.leadingAnchor.constraint(equalTo: legendContainer.leadingAnchor, constant: 20),
                legend.trailingAnchor.constraint(equalTo: legendContainer.trailingAnchor, constant: -20),
                legendContainer.bottomAnchor.constraint(equalTo: legend.bottomAnchor)
            ])
        }
    }
}
