//
//  TodayViewController.swift
//  DuffyToday
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import NotificationCenter
import DuffyFramework

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var stepsValueLabel : UILabel?
    
    let numFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        numFormatter.numberStyle = .decimal
        numFormatter.locale = Locale.current
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
               
        let cachedStepCount = HealthCache.getStepsFromSharedCache(forDay: Date())
        stepsValueLabel?.text = numFormatter.string(from: NSNumber(value:cachedStepCount))
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
