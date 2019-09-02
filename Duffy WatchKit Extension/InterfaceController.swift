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
    @IBOutlet weak var distanceValueLabel : WKInterfaceLabel?
    @IBOutlet weak var flightsValueLabel : WKInterfaceLabel?
    
    private let refreshInterval = 3.0
    private let autoRefreshMax = 10
    private var isQueryInProgress = false
    private var timer: Timer? {
        didSet {
            currentRefreshCount = 0
        }
    }
    private var currentRefreshCount = 0
    
    override func didAppear()
    {
        super.didAppear()
        
        askForHealthKitPermission()
    }
    
    override func willDisappear() {
        super.willDisappear()
        stopAutomaticUpdates()
    }
    
    private func askForHealthKitPermission()
    {
        //reset display if day turned over
        if (HealthCache.cacheIsForADifferentDay(Date()))
        {
            display(steps: 0)
        }
        
        HealthKitService.getInstance().authorizeForAllData({
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                    self?.refresh()
                })
            
            }, onFailure: { })
    }
    
    private func refresh()
    {
        showLoading()
        refreshTodayFromHealth({
            [weak self] success in
            
            if let weakSelf = self {
                self?.hideLoading()
            
                if success {
                    weakSelf.startAutomaticUpdates()
                    weakSelf.scheduleSnapshot()
                }
            }
        })
    }
    
    private func scheduleSnapshot() {
        if let d = WKExtension.shared().delegate as? ExtensionDelegate
        {
            d.scheduleNextBackgroundRefresh()
            d.scheduleSnapshotNow()
        }
    }
    
    private func refreshTodayFromHealth(_ completion: @escaping (Bool) -> Void) {
        isQueryInProgress = true
        let failBlock = {
            [weak self] in
            self?.isQueryInProgress = false
            completion(false)
        }
        
        displayTodaysStepsFromHealth({
            [weak self] success in
            if success {
                self?.displayTodaysFlightsFromHealth({
                    [weak self] success in
                    if success {
                        self?.displayTodaysDistanceFromHealth({
                            [weak self] success in
                            self?.isQueryInProgress = false
                            completion(success)
                        })
                    } else {
                        failBlock()
                    }
                })
            } else {
                failBlock()
            }
        })
    }
    
    private func displayTodaysStepsFromHealth(_ completion: @escaping (Bool) -> Void)
    {
        HealthKitService.getInstance().getSteps(Date(),
            onRetrieve: {
                (stepsCount: Int, forDate: Date) in
                
                DispatchQueue.main.async {
                    [weak self] in
                    self?.display(steps: stepsCount)
                    completion(true)
                }
            },
            onFailure: {
                (error: Error?) in
                
                DispatchQueue.main.async {
                    [weak self] in
                    self?.displayTodaysStepsFromCache()
                    completion(false)
                }
            })
    }
    
    private func displayTodaysFlightsFromHealth(_ completion: @escaping (Bool) -> Void) {
        HealthKitService.getInstance().getFlightsClimbed(Date(), onRetrieve: {
            flights, date in
            
            DispatchQueue.main.async {
                [weak self] in
                self?.flightsValueLabel?.setText(InterfaceController.getNumberFormatter().string(from: NSNumber(value: flights)))
                completion(true)
            }
            
        }, onFailure: {
            error in
            completion(false)
        })
    }
    
    func displayTodaysDistanceFromHealth(_ completion: @escaping (Bool) -> Void) {
        HealthKitService.getInstance().getDistanceCovered(Date(), onRetrieve: {
            distance, units, date in
            
            DispatchQueue.main.async {
                [weak self] in
                let formatter = InterfaceController.getNumberFormatter()
                formatter.maximumFractionDigits = 1
                let unitsFormatted = units == .mile ? "mi" : "km"
                if let weakSelf = self, let valueFormatted = formatter.string(from: NSNumber(value: distance)) {
                    let distanceAttributed = NSMutableAttributedString(string: String(format: "%@ %@", valueFormatted, unitsFormatted))
                    distanceAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 10.0), range: NSRange(location: distanceAttributed.string.count - unitsFormatted.count, length: unitsFormatted.count))
                    weakSelf.distanceValueLabel?.setAttributedText(distanceAttributed)
                }
                completion(true)
            }
            
        }, onFailure: {
            error in
            completion(false)
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
        setTitle("Today")
    }
    
    private func display(steps: Int)
    {
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
                lbl.setText(String(format: "of %@ goal %@", formattedValue, HealthKitService.getInstance().getAdornment(for: stepsForDay)))
            }
            else
            {
                lbl.setHidden(true)
            }
        }
    }
    
    private func startAutomaticUpdates() {
        guard timer == nil else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true, block: {
            [weak self] (t: Timer) in
            
            if WKExtension.shared().applicationState != .active {
                return
            }
            
            if let weakSelf = self, !weakSelf.isQueryInProgress, weakSelf.currentRefreshCount < weakSelf.autoRefreshMax {
                weakSelf.refreshTodayFromHealth({
                    [weak self] success in
                    self?.scheduleSnapshot()
                })
                weakSelf.currentRefreshCount += 1
            }
        })
    }
    
    private func stopAutomaticUpdates() {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = nil
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
