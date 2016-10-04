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
    @IBOutlet weak var refreshButton : UIButton?
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
        refreshButton?.setTitleColor(primaryColor, for: UIControlState())
        titleLabel?.textColor = primaryColor
        subTitleLabel?.textColor = primaryColor
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        refresh()
    }
    
    fileprivate func askForHealthKitPermission()
    {
        HealthKitService.getInstance().authorizeForSteps({

            DispatchQueue.main.async(execute: {
                [weak self] (_) in
                self?.displayTodaysStepsFromHealth()
            })


        }, onFailure: {
            NSLog("Did not authorize")
        })
    }

    fileprivate func displayTodaysStepsFromHealth()
    {
        showLoading()

        HealthKitService.getInstance().getSteps(Date(),
            onRetrieve: {
                (stepsCount: Int, forDate: Date) in

                DispatchQueue.main.async(execute: {
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()

                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = NumberFormatter.Style.decimal
                        numberFormatter.locale = Locale.current
                        numberFormatter.maximumFractionDigits = 0

                        weakSelf.stepsValueLabel?.text = numberFormatter.string(from: NSNumber(value: stepsCount))
                    }
                })
            },
            onFailure:  {
                [weak self] (error: Error?) in

                if let e = error
                {
                    NSLog(String(format:"ERROR: %@", e.localizedDescription))
                }

                DispatchQueue.main.async(execute: {
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()
                        weakSelf.stepsValueLabel?.text = "ERR"
                    }
                })
        })
    }

    fileprivate func showLoading()
    {
        loadingContainer?.isHidden = false
        loadingSpinner?.startAnimating()
    }

    fileprivate func hideLoading()
    {
        loadingSpinner?.stopAnimating()
        loadingContainer?.isHidden = true
    }

    func refresh()
    {
        askForHealthKitPermission()
    }
    
    @IBAction func refreshPressed()
    {
        refresh()
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
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alertContoller.view.tintColor = primaryColor
        alertContoller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alertContoller, animated: true, completion: nil)
    }
}

