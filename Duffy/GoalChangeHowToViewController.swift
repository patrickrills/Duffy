//
//  GoalChangeHowToViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/25/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit

class GoalChangeHowToViewController: UIViewController {

    init() {
        super.init(nibName: "GoalChangeHowToViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "How To Change Goal"
    }
}
