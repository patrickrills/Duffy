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

class MainInterfaceController: WKInterfaceController
{
    @IBOutlet weak var stepsTitleLabel : WKInterfaceLabel!
    @IBOutlet weak var stepsValueLabel : WKInterfaceLabel!
    @IBOutlet weak var ringImage: WKInterfaceImage!
    @IBOutlet weak var stepsGoalTitleLabel : WKInterfaceLabel!
    @IBOutlet weak var stepsGoalLabel : WKInterfaceLabel!
    @IBOutlet weak var distanceTitleLabel : WKInterfaceLabel!
    @IBOutlet weak var distanceValueLabel : WKInterfaceLabel!
    @IBOutlet weak var flightsTitleLabel : WKInterfaceLabel!
    @IBOutlet weak var flightsValueLabel : WKInterfaceLabel!
    @IBOutlet weak var summaryButtonImage : WKInterfaceImage!
    @IBOutlet weak var summaryButtonLabel : WKInterfaceLabel!
    @IBOutlet weak var goalButtonImage : WKInterfaceImage!
    @IBOutlet weak var goalButtonLabel : WKInterfaceLabel!
    @IBOutlet weak var debugButton: WKInterfaceButton!
    @IBOutlet weak var topSeparator: WKInterfaceGroup!
    @IBOutlet weak var bottomSeparator: WKInterfaceGroup!
    
    private var isQueryInProgress = false
    
    //MARK: Controller Lifecycle
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        initializeUI()
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
    
    @IBAction func openSummary() {
        presentController(withName: SummaryInterfaceController.IDENTIFIER, context: nil)
    }
    
    @IBAction func openSetGoal() {
        var controllerId = LegacyEditGoalInterfaceController.IDENTIFIER
        if #available(watchOS 6.0, *) {
            controllerId = SetGoalInterfaceController.IDENTIFIER
        }
        presentController(withName: controllerId, context: nil)
    }
    
    //MARK: Update UI
    
    func refresh() {
        refreshTodayFromHealth({
            [weak self] success in
            
            if let weakSelf = self, success {
                weakSelf.scheduleSnapshot()
            }
        })
    }
    
    private func display(steps: Steps) {
        let stepsFormatted = Globals.integerFormatter.string(for: steps)!
        stepsValueLabel.setAttributedText(NSAttributedString(string: stepsFormatted, attributes: [.font : Globals.roundedFont(of: 40, weight: .regular), .foregroundColor: UIColor.white]))
        updateGoalDisplay(stepsForDay: steps)
    }
    
    private func updateGoalDisplay(stepsForDay: Steps) {
        let goalValue = HealthCache.dailyGoal()
        if goalValue > 0, let formattedValue = Globals.integerFormatter.string(for: goalValue) {
            ringImage.setImage(RingDrawer.drawRing(stepsForDay, goal: goalValue, width: 60, includeCenterImage: false)?.withRenderingMode(.alwaysTemplate))
            stepsGoalLabel.setHidden(false)
//            stepsGoalLabel.setText(String(format: NSLocalizedString("of %@ goal %@", comment: ""), formattedValue, Trophy.trophy(for: stepsForDay).symbol()))
            setRoundedText(formattedValue, for: stepsGoalLabel, in: .white)
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
                    if let flightsValueLabel = self?.flightsValueLabel,
                       let flightsFormatted = Globals.integerFormatter.string(for: flightsResult.flights)
                    {
                        self?.setRoundedText(flightsFormatted, for: flightsValueLabel)
                    }
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
                let formatter = Globals.decimalFormatter
                let unitsFormatted = distanceResult.formatter == .mile ? NSLocalizedString("Miles", comment: "") : NSLocalizedString("Kilometers", comment: "")
                if let valueFormatted = formatter.string(for: distanceResult.distance) {
                    DispatchQueue.main.async { [weak self] in
                        if let distanceValueLabel = self?.distanceValueLabel,
                           let distanceTitleLabel = self?.distanceTitleLabel
                        {
                            self?.setRoundedText(valueFormatted, for: distanceValueLabel)
                            self?.setRoundedText(unitsFormatted, for: distanceTitleLabel)
                        }
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
    
    //MARK: Build UI
    
    private let BUTTON_FONT_SIZE: CGFloat = 16.0
    private let BUTTON_FONT_WEIGHT: UIFont.Weight = .semibold
    
    private func initializeUI() {
        setTitle(NSLocalizedString("Today", comment: ""))
        debugButton.setHidden(!DebugService.isDebugModeEnabled())
        ringImage.setTintColor(Globals.secondaryColor())
        initializeSeparator(topSeparator)
        initializeSeparator(bottomSeparator)
        
        stepsGoalLabel.setTextColor(.white)
        flightsValueLabel.setTextColor(Globals.secondaryColor())
        distanceValueLabel.setTextColor(Globals.secondaryColor())
        
        let summaryButtonText = NSLocalizedString("View Summary", comment: "")
        let goalButtonText = NSLocalizedString("Change Goal", comment: "")
        let stepsTitle = NSLocalizedString("Steps", comment: "")
        let flightsTitle = NSLocalizedString("Flights", comment: "")
        let distanceTitle = NSLocalizedString("Distance", comment: "")
        let goalTitle = NSLocalizedString("Goal", comment: "")
        
        if #available(watchOS 6.0, *) {
            let buttonFont = Globals.roundedFont(of: BUTTON_FONT_SIZE, weight: BUTTON_FONT_WEIGHT)
            let symbolConfiguration = UIImage.SymbolConfiguration(font: buttonFont)
            
            summaryButtonImage.setImage(UIImage(systemName: "calendar", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate))
            summaryButtonLabel.setAttributedText(NSAttributedString(string: summaryButtonText, attributes: [.font : buttonFont]))
            
            var goalImageName = "speedometer"
            if #available(watchOS 7.0, *) {
                goalImageName = "figure.walk"
            }
            goalButtonImage.setImage(UIImage(systemName: goalImageName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate))
            goalButtonLabel.setAttributedText(NSAttributedString(string: goalButtonText, attributes: [.font : buttonFont]))
            
            setRoundedText(stepsTitle, for: stepsTitleLabel)
            setRoundedText(goalTitle, for: stepsGoalTitleLabel, in: .white)
            setRoundedText(flightsTitle, for: flightsTitleLabel)
            setRoundedText(distanceTitle, for: distanceTitleLabel)
        } else {
            summaryButtonImage.setHidden(true)
            summaryButtonLabel.setText(summaryButtonText)
            goalButtonImage.setHidden(true)
            goalButtonLabel.setText(goalButtonText)
            stepsTitleLabel.setText(stepsTitle)
            stepsTitleLabel.setTextColor(Globals.secondaryColor())
            flightsTitleLabel.setText(flightsTitle)
            flightsTitleLabel.setTextColor(Globals.secondaryColor())
            distanceTitleLabel.setText(distanceTitle)
            distanceTitleLabel.setTextColor(Globals.secondaryColor())
            stepsGoalTitleLabel.setText(goalTitle)
            stepsGoalTitleLabel.setTextColor(.white)
        }
    }
    
    private func initializeSeparator(_ separator: WKInterfaceGroup) {
        separator.setHeight(1.0)
        separator.setCornerRadius(1.0)
        separator.setBackgroundColor(Globals.dividerColor())
    }
    
    private func setRoundedText(_ text: String, for label: WKInterfaceLabel) {
        setRoundedText(text, for: label, in: Globals.secondaryColor())
    }
    
    private func setRoundedText(_ text: String, for label: WKInterfaceLabel, in color: UIColor) {
        label.setAttributedText(NSAttributedString(string: text, attributes: [.font : Globals.roundedFont(of: 16, weight: .regular), .foregroundColor: color]))
    }
    
    //MARK: DEBUG
    
    @IBAction func openDebug() {
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
