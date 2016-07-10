//
//  ViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class ViewController: UIViewController
{
    @IBOutlet weak var stepsValueLabel : UILabel?
    @IBOutlet weak var stepsTextLabel : UILabel?
    @IBOutlet weak var loadingContainer : UIView?
    @IBOutlet weak var loadingSpinner : UIActivityIndicatorView?
    @IBOutlet weak var infoButton : UIButton?
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var subTitleLabel : UILabel?
    
    let primaryColor = UIColor(red: 0.0, green: 61.0/255.0, blue: 165.0/255.0, alpha: 1.0)

    override func viewDidLoad()
    {
        super.viewDidLoad()

        //TODO: colors

        loadingContainer?.layer.cornerRadius = 8.0
        loadingContainer?.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.85)
        stepsTextLabel?.textColor = primaryColor
        infoButton?.tintColor = primaryColor
        titleLabel?.textColor = primaryColor
        subTitleLabel?.textColor = primaryColor
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        refresh()
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

    private func displayTodaysStepsFromHealth()
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

                        weakSelf.stepsValueLabel?.text = numberFormatter.stringFromNumber(stepsCount)
                    }
                })
            },
            onFailure:  {
                [weak self] (error: NSError?) in

                if let e = error
                {
                    NSLog(String(format:"ERROR: %@", e.localizedDescription))
                }

                dispatch_async(dispatch_get_main_queue(),{
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()
                        weakSelf.stepsValueLabel?.text = "ERR"
                    }
                })
        })
    }

    private func showLoading()
    {
        loadingContainer?.hidden = false
        loadingSpinner?.startAnimating()
    }

    private func hideLoading()
    {
        loadingSpinner?.stopAnimating()
        loadingContainer?.hidden = true
    }

    func refresh()
    {
        askForHealthKitPermission()
    }
    
    @IBAction func infoPressed()
    {
        let cacheData = HealthCache.getStepsDataFromCache()
        var date = "Unknown"
        var steps = -1
        if let savedDay = cacheData["stepsCacheDay"] as? String
        {
            date = savedDay
        }
        if let savedVal = cacheData["stepsCacheValue"] as? Int
        {
            steps = savedVal
        }
        
        let message = String(format: "Saved in cache:\n Steps: %d\n For day: %@", steps, date)
        let title = "Info"
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .Alert);
        alertContoller.view.tintColor = primaryColor
        alertContoller.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        presentViewController(alertContoller, animated: true, completion: nil)
    }
}

