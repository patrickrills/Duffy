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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if DebugService.isDebugModeEnabled() {
            addMenuItem(with: .info, title: "Debug", action: #selector(debugPressed))
        }
    }
    
    override func willActivate() {
        super.willActivate()
        maybeTurnOverComplicationDate()
        refresh()
    }
    
    override func didAppear()
    {
        super.didAppear()
        askForHealthKitPermissionAndRefresh()
    }
    
    override func willDisappear() {
        super.willDisappear()
        stopAutomaticUpdates()
    }
    
    private func askForHealthKitPermissionAndRefresh()
    {
        maybeTurnOverComplicationDate()
        
        HealthKitService.getInstance().authorizeForAllData({
            
            DispatchQueue.main.async {
                [weak self] in
                    self?.refresh()
                }
            
            }, onFailure: { })
    }
    
    private func refresh()
    {
        refreshTodayFromHealth({
            [weak self] success in
            
            if let weakSelf = self, success {
                weakSelf.startAutomaticUpdates()
                weakSelf.scheduleSnapshot()
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
        guard !isQueryInProgress else { return }
        
        isQueryInProgress = true

        let refreshGroup = DispatchGroup()
        
        //steps
        var stepsSuccess = false
        refreshGroup.enter()
        displayTodaysStepsFromHealth({ success in
            stepsSuccess = success
            refreshGroup.leave()
        })
        
        //flights
        var flightsSuccess = false
        refreshGroup.enter()
        displayTodaysFlightsFromHealth({ success in
            flightsSuccess = success
            refreshGroup.leave()
        })
        
        //distance
        var distanceSuccess = false
        refreshGroup.enter()
        displayTodaysDistanceFromHealth({ success in
            distanceSuccess = success
            refreshGroup.leave()
        })
        
        refreshGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: { [weak self] in
            if let self = self {
                self.isQueryInProgress = false
            }
            completion(stepsSuccess && flightsSuccess && distanceSuccess)
        }))
    }
    
    private func displayTodaysStepsFromHealth(_ completion: @escaping (Bool) -> Void)
    {
        HealthKitService.getInstance().getSteps(Date(),
            onRetrieve: {
                [weak self] (stepsCount: Int, forDate: Date) in
                
                self?.maybeUpdateComplication(with: stepsCount, for: forDate)
                
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
                let unitsFormatted = units == .mile ? NSLocalizedString("mi", comment: "") : NSLocalizedString("km", comment: "")
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
    
    func updateInterfaceFromSnapshot()
    {
        displayTodaysStepsFromCache()
        LoggingService.log("Update UI from snapshot task")
    }
    
    private func displayTodaysStepsFromCache()
    {
        DispatchQueue.main.async {
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
        }
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
                lbl.setText(String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedValue, Trophy.trophy(for: stepsForDay).symbol()))
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
        isQueryInProgress = false
    }
    
    private func maybeTurnOverComplicationDate() {
        //reset display if day turned over
        if (HealthCache.cacheIsForADifferentDay(Date())) {
            display(steps: 0)
            maybeUpdateComplication(with: 0, for: Date())
        }
    }
    
    private func maybeUpdateComplication(with stepCount: Int, for day: Date) {
        if HealthCache.saveStepsToCache(stepCount, forDay: day) {
            LoggingService.log("Update complication from watch UI", with: "\(stepCount)")
            ComplicationController.refreshComplication()
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
    
    @IBAction func debugPressed()
    {
        let log = LoggingService.getFullDebugLog()
        if log.count > 0 {
            var actions = [WKAlertAction]()
            
            let numberOfDays = LoggingService.getDatesFromDebugLog()
            if numberOfDays.count > 2 {
                let lastDay = numberOfDays[0]
                let lastDayMinus1 = numberOfDays[1]
                let lastDayMinus2 = numberOfDays[2]
                
                actions.append(WKAlertAction(title: "Last 2 Days", style: .default, handler: {
                    [weak self] in
                    self?.sendDebugLogToPhone(LoggingService.getPartialDebugLog(from: lastDayMinus1, to: lastDay))
                }))
                
                if let lastDayMinus3 = Calendar.current.date(byAdding: .day, value: -1, to: lastDayMinus2) {
                    actions.append(WKAlertAction(title: "Previous 2 Days", style: .default, handler: {
                        [weak self] in
                        self?.sendDebugLogToPhone(LoggingService.getPartialDebugLog(from: lastDayMinus3, to: lastDayMinus2))
                    }))
                }
            }
            
            if numberOfDays.count > 4 {
                let lastDayMinus4 = numberOfDays[4]
                if let lastDayMinus5 = Calendar.current.date(byAdding: .day, value: -1, to: lastDayMinus4) {
                    actions.append(WKAlertAction(title: "2 Days Before That", style: .default, handler: {
                        [weak self] in
                        self?.sendDebugLogToPhone(LoggingService.getPartialDebugLog(from: lastDayMinus5, to: lastDayMinus4))
                    }))
                }
            }
            
            actions.append(contentsOf: [
                WKAlertAction(title: "Send Entire Log", style: .default, handler: {
                    [weak self] in
                    self?.sendDebugLogToPhone(LoggingService.getFullDebugLog())
                }),
                WKAlertAction(title: "Clear Log", style: .destructive, handler: {
                    [weak self] in
                    self?.clearDebugLog()
                }),
                WKAlertAction(title: "Dismiss", style: .cancel, handler: {})
            ])
            
            presentAlert(withTitle: "\(log.count) Entries", message: log[0].message, preferredStyle: .actionSheet, actions: actions)
        }
    }
    
    private func sendDebugLogToPhone(_ entries: [DebugLogEntry]) {
        WCSessionService.getInstance().sendDebugLog(entries, onCompletion: {
            [weak self] success in
            DispatchQueue.main.async {
                self?.presentAlert(withTitle: "Log Transfer", message: (success ? "Log sent to phone" : "Error sending log"), preferredStyle: .alert, actions: [
                    WKAlertAction(title: "Dismiss", style: .cancel, handler: {})
                ])
            }
        })
    }
    
    private func clearDebugLog() {
        LoggingService.clearLog()
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
