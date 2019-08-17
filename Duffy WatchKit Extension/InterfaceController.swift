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
import HealthKit

class InterfaceController: WKInterfaceController
{
    @IBOutlet weak var stepsValueLabel : WKInterfaceLabel?
    @IBOutlet weak var stepsGoalLabel : WKInterfaceLabel?
    
    override func didAppear()
    {
        super.didAppear()
        
        askForHealthKitPermission()
    }
    
    override func willDisappear() {
        super.willDisappear()
        HealthKitService.getInstance().unsubscribe(from: HKQuantityTypeIdentifier.stepCount)
    }
    
    fileprivate func askForHealthKitPermission()
    {
        //reset display if day turned over
        if (HealthCache.cacheIsForADifferentDay(Date()))
        {
            display(steps: 0)
        }
        
        HealthKitService.getInstance().authorizeForSteps({
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                    self?.refresh()
                    self?.subscribeToSteps()
                })
            
            }, onFailure: { })
    }
    
    fileprivate func refresh()
    {
        showLoading()
        displayTodaysStepsFromHealth()
        if let d = WKExtension.shared().delegate as? ExtensionDelegate
        {
            d.scheduleNextBackgroundRefresh()
            d.scheduleSnapshotNow()
        }
    }
    
    private func subscribeToSteps() {
        HealthKitService.getInstance().subscribe(to: HKQuantityTypeIdentifier.stepCount, on: {
            [weak self] in
            self?.displayTodaysStepsFromHealth()
        })
    }
    
    func displayTodaysStepsFromHealth()
    {
        HealthKitService.getInstance().getSteps(Date(),
            onRetrieve: {
                (stepsCount: Int, forDate: Date) in
                
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    self?.display(steps: stepsCount)
                })
            },
            onFailure: {
                (error: Error?) in
                
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    self?.displayTodaysStepsFromCache()
                })
            })
    }
    
    func displayTodaysStepsFromCache()
    {
        DispatchQueue.main.async(execute: {
            [weak self] in
            
            if let weakSelf = self
            {
                var steps = 0
                
                if (!HealthCache.cacheIsForADifferentDay(Date()))
                {
                    let cacheData = HealthCache.getStepsDataFromCache()
                    if let savedVal = cacheData["stepsCacheValue"] as? Int
                    {
                        steps = savedVal
                    }
                }
                
                weakSelf.display(steps: steps)
            }
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
    
    private func display(steps: Int)
    {
        hideLoading()
        stepsValueLabel?.setText(InterfaceController.getNumberFormatter().string(from: NSNumber(value: steps)))
        updateGoalDisplay(stepsForDay: steps)
    }
    
    private func updateGoalDisplay(stepsForDay: Int)
    {
        if let lbl = stepsGoalLabel
        {
            let goalValue = HealthCache.getStepsDailyGoal()
            if goalValue > 0, let formattedValue = InterfaceController.getNumberFormatter().string(from: NSNumber(value: goalValue))
            {
                lbl.setHidden(false)
                lbl.setText(String(format: "of %@ %@", formattedValue, HealthKitService.getInstance().getAdornment(for: stepsForDay)))
            }
            else
            {
                lbl.setHidden(true)
            }
        }
    }
    
    @IBAction func refreshPressed()
    {
        refresh()
    }
    
    @IBAction func changeGoalMenuItemPressed()
    {
        presentController(withName: "editGoalInterfaceController", context: nil)
    }
    
    open class func getNumberFormatter() -> NumberFormatter
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }
}
