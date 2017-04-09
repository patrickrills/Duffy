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
    @IBOutlet weak var goalLabel : UILabel?
    
    open static let primaryColor = UIColor(red: 0.0, green: 61.0/255.0, blue: 165.0/255.0, alpha: 1.0)
    let secondaryColor = UIColor(red: 76.0/255.0, green: 142.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    let numberFormatter = NumberFormatter()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0

        loadingContainer?.layer.cornerRadius = 8.0
        loadingContainer?.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.85)
        stepsTextLabel?.textColor = ViewController.primaryColor
        infoButton?.tintColor = secondaryColor
        refreshButton?.setTitleColor(secondaryColor, for: UIControlState())
        titleLabel?.textColor = ViewController.primaryColor
        subTitleLabel?.textColor = ViewController.primaryColor
        updateGoalDisplay()
        
        infoButton?.isHidden = !Constants.isDebugMode
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
            //NSLog("Did not authorize")
        })
    }

    fileprivate func displayTodaysStepsFromHealth()
    {
        updateGoalDisplay()
        showLoading()

        HealthKitService.getInstance().getSteps(Date(),
            onRetrieve: {
                (stepsCount: Int, forDate: Date) in

                DispatchQueue.main.async(execute: {
                    [weak self] (_) in
                    if let weakSelf = self
                    {
                        weakSelf.hideLoading()
                        weakSelf.stepsValueLabel?.text = weakSelf.numberFormatter.string(from: NSNumber(value: stepsCount))
                    }
                })
            },
            onFailure:  {
                [weak self] (error: Error?) in
                /*
                if let e = error
                {
                    NSLog(String(format:"ERROR: %@", e.localizedDescription))
                }
                */

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
    
    @IBAction func pastWeekPressed()
    {
        let weekVC = WeekViewController()
        let modalNav = UINavigationController(rootViewController: weekVC)
        modalNav.navigationBar.tintColor = secondaryColor
        present(modalNav, animated: true, completion: nil)
    }
    
    @IBAction func infoPressed()
    {
        refresh()
        
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
        alertContoller.view.tintColor = ViewController.primaryColor
        alertContoller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alertContoller, animated: true, completion: nil)
    }
    
    @IBAction func versionPressed()
    {
        let message = String(format: "Version: %@.%@", valueFromBundle(forKey: "CFBundleShortVersionString"), valueFromBundle(forKey: "CFBundleVersion"))
        let title = "About"
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert);
        alertContoller.view.tintColor = ViewController.primaryColor
        alertContoller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alertContoller, animated: true, completion: nil)
    }
    
    private func valueFromBundle(forKey: String) -> String
    {
        if let localvals = Bundle.main.localizedInfoDictionary {
            if let v = localvals[forKey] as? String {
                return v
            }
        }
        
        if let infovals = Bundle.main.infoDictionary {
            if let v = infovals[forKey] as? String {
                return v
            }
        }
        
        return ""
    }
    
    private func updateGoalDisplay()
    {
        if let lbl = goalLabel
        {
            let goalValue = HealthCache.getStepsDailyGoal()
            if goalValue > 0, let formattedValue = numberFormatter.string(from: NSNumber(value: goalValue)) {
                lbl.text = String(format: "of %@", formattedValue)
            } else {
                lbl.text = ""
            }
        }
    }
}

