//
//  HourGraphDetailViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/15/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HourGraphDetailViewController: DetailDataViewPageViewController
{
    @IBOutlet weak var barsStackView : UIStackView?
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        print("bar count: \(barsStackView!.arrangedSubviews.count)")
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        bottomConstraint?.constant = margin.bottom
    }
}
