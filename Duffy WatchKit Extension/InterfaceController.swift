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
    @IBOutlet weak var stepsValueLabel : WKInterfaceLabel!
    @IBOutlet weak var stepsGoalLabel : WKInterfaceLabel!
    @IBOutlet weak var distanceValueLabel : WKInterfaceLabel!
    @IBOutlet weak var flightsValueLabel : WKInterfaceLabel!
    
    private var isQueryInProgress = false
    
    //MARK: Globals
    
    public class func getNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }
    
    //MARK: Controller Lifecycle
    
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
    
    override func didAppear() {
        super.didAppear()
        askForHealthKitPermissionAndRefresh()
        subscribeToHealthKitUpdates()
    }
    
    override func willDisappear() {
        super.willDisappear()
        unsubscribeToHealthKitUpdates()
    }
    
    //MARK: Menu Button Handlers
    
    @IBAction func refreshPressed() {
        refresh()
    }
    
    @IBAction func changeGoalMenuItemPressed() {
        let controllerId = DebugService.isDebugModeEnabled() ? SetGoalInterfaceController.IDENTIFIER : LegacyEditGoalInterfaceController.IDENTIFIER
        presentController(withName: controllerId, context: nil)
    }
    
    //MARK: Update UI
    
    private func refresh() {
        refreshTodayFromHealth({
            [weak self] success in
            
            if let weakSelf = self, success {
                weakSelf.scheduleSnapshot()
            }
        })
    }
    
    private func display(steps: Steps) {
        stepsValueLabel?.setText(InterfaceController.getNumberFormatter().string(for: steps))
        updateGoalDisplay(stepsForDay: steps)
    }
    
    private func updateGoalDisplay(stepsForDay: Steps) {
        let goalValue = HealthCache.dailyGoal()
        if goalValue > 0, let formattedValue = InterfaceController.getNumberFormatter().string(for: goalValue) {
            stepsGoalLabel.setHidden(false)
            stepsGoalLabel.setText(String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedValue, Trophy.trophy(for: stepsForDay).symbol()))
        } else {
            stepsGoalLabel.setHidden(true)
        }
    }
    
    //MARK: Apple Health Integration
    
    private func askForHealthKitPermissionAndRefresh() {
        maybeTurnOverComplicationDate()
        
        HealthKitService.getInstance().authorize { success in
            guard success else { return }
            DispatchQueue.main.async { [weak self] in
                self?.refresh()
            }
        }
    }
    
    private func refreshTodayFromHealth(_ completion: @escaping (Bool) -> ()) {
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
        
        refreshGroup.notify(queue: DispatchQueue.main) { [weak self] in
            if let self = self {
                self.isQueryInProgress = false
            }
            completion(stepsSuccess && flightsSuccess && distanceSuccess)
        }
    }
    
    private func displayTodaysStepsFromHealth(_ completion: @escaping (Bool) -> Void) {
        HealthKitService.getInstance().getSteps(for: Date()) { [weak self] result in
            switch result {
            case .success(let stepsResult):
                self?.maybeUpdateComplication(with: stepsResult.steps, for: stepsResult.day)
                DispatchQueue.main.async {
                    self?.display(steps: stepsResult.steps)
                    completion(true)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self?.displayTodaysStepsFromCache()
                    completion(false)
                }
            }
        }
    }
    
    private func displayTodaysFlightsFromHealth(_ completion: @escaping (Bool) -> Void) {
        HealthKitService.getInstance().getFlightsClimbed(for: Date()) { result in
            switch result {
            case .success(let flightsResult):
                DispatchQueue.main.async { [weak self] in
                    self?.flightsValueLabel?.setText(InterfaceController.getNumberFormatter().string(for: flightsResult.flights))
                    completion(true)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func displayTodaysDistanceFromHealth(_ completion: @escaping (Bool) -> Void) {
        HealthKitService.getInstance().getDistanceCovered(for: Date()) { result in
            switch result {
            case .success(let distanceResult):
                let formatter = InterfaceController.getNumberFormatter()
                formatter.maximumFractionDigits = 1
                let unitsFormatted = distanceResult.formatter == .mile ? NSLocalizedString("mi", comment: "") : NSLocalizedString("km", comment: "")
                if let valueFormatted = formatter.string(for: distanceResult.distance) {
                    let distanceAttributed = NSMutableAttributedString(string: String(format: "%@ %@", valueFormatted, unitsFormatted))
                    distanceAttributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 10.0), range: NSRange(location: distanceAttributed.string.count - unitsFormatted.count, length: unitsFormatted.count))
                    DispatchQueue.main.async { [weak self] in
                        self?.distanceValueLabel?.setAttributedText(distanceAttributed)
                    }
                }
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    //MARK: Apple Health Subscription
    
    func subscribeToHealthKitUpdates() {
        HealthKitService.getInstance().initializeBackgroundQueries()
        
        HealthKitService.getInstance().subscribe(to: HKQuantityTypeIdentifier.stepCount, on: {
            DispatchQueue.main.async {
                [weak self] in
                
                if WKExtension.shared().applicationState != .active {
                    return
                }
                
                if let weakSelf = self, !weakSelf.isQueryInProgress {
                    LoggingService.log("Refreshing from update subscriber")
                    weakSelf.refreshTodayFromHealth({
                        [weak self] success in
                        self?.scheduleSnapshot()
                    })
                }
            }
        })
    }
    
    func unsubscribeToHealthKitUpdates() {
        HealthKitService.getInstance().unsubscribe(from: HKQuantityTypeIdentifier.stepCount)
        isQueryInProgress = false
    }
    
    //MARK: Snapshot and Complication Updating
    
    private func scheduleSnapshot() {
        if let d = WKExtension.shared().delegate as? ExtensionDelegate {
            d.scheduleNextBackgroundRefresh()
            d.scheduleSnapshotNow()
        }
    }
    
    func updateInterfaceFromSnapshot() {
        displayTodaysStepsFromCache()
        LoggingService.log("Update UI from snapshot task")
    }
    
    private func displayTodaysStepsFromCache() {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.display(steps: HealthCache.lastSteps(for: Date()))
        }
    }
    
    private func maybeTurnOverComplicationDate() {
        //reset display if day turned over
        if HealthCache.cacheIsForADifferentDay(than: Date()) {
            display(steps: 0)
            maybeUpdateComplication(with: 0, for: Date())
        }
    }
    
    private func maybeUpdateComplication(with stepCount: Steps, for day: Date) {
        if HealthCache.saveStepsToCache(stepCount, for: day) {
            LoggingService.log("Update complication from watch UI", with: "\(stepCount)")
            ComplicationController.refreshComplication()
        }
    }
    
    //MARK: DEBUG
    
    @IBAction func debugPressed() {
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
}
