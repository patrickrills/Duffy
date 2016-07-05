//
//  InterfaceController.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import Foundation
import DuffyWatchFramework

class InterfaceController: WKInterfaceController
{
    @IBOutlet weak var stepsValueLabel : WKInterfaceLabel?

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        askForHealthKitPermission()
    }
    
    private func askForHealthKitPermission()
    {
        HealthKitService.getInstance().authorizeForSteps({
            
            dispatch_async(dispatch_get_main_queue(),{
                [weak self] (_) in
                self?.displayTodaysStepsFromHealth()
                })
            
            
            }, onFailure: {
                NSLog("Did not authorize")
        })
    }
    
    func displayTodaysStepsFromHealth()
    {
        showLoading()
        
        HealthKitService.getInstance().getSteps(NSDate(),
            onRetrieve: {
                (stepsCount: Int, forDate: NSDate) in
                
                dispatch_async(dispatch_get_main_queue(),{
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()
                        
                        let numberFormatter = NSNumberFormatter()
                        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                        numberFormatter.locale = NSLocale.currentLocale()
                        numberFormatter.maximumFractionDigits = 0
                        
                        weakSelf.stepsValueLabel?.setText(numberFormatter.stringFromNumber(stepsCount))
                    }
                })
            },
            onFailure:  {
                (error: NSError?) in
                if let e = error
                {
                    NSLog(String(format:"ERROR: %@", e.localizedDescription))
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()
                        weakSelf.stepsValueLabel?.setText("ERR")
                    }
                })
            })
    }
    
    func showLoading()
    {
        setTitle("Getting...")
    }
    
    func hideLoading()
    {
        setTitle("Duffy")
    }
}
