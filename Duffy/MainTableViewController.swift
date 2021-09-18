//
//  MainTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 6/23/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework
import HealthKit

class MainTableViewController: UITableViewController {
    
    private var goal: Steps = 0
    private var todaysFlights: FlightsClimbed = 0
    private var todaysDistance: DistanceTravelled = 0
    private var distanceUnit: LengthFormatter.Unit = .mile
    private var stepsByHour: [Hour : Steps] = [:]
    private var sortedKeys: [Date] = []
    
    private var steps: [Date : Steps] = [:] {
        didSet {
            sortedKeys = pastWeekSteps.keys.sorted(by: >)
        }
    }
    
    private var todaysSteps: Steps {
        return steps.first(where: { $0.key.isToday() })?.value ?? 0
    }
    
    private var pastWeekSteps: [Date : Steps] {
        return steps.filter { !$0.key.isToday() && $0.key >= Date().stripTime().dateByAdding(days: -7) }
    }
    
    private var isLoading: Bool = false {
        didSet {
            if #available(iOS 13.0, *) {
                getHeader()?.isLoading = isLoading
            }
        }
    }
    
    private enum Constants {
        static let ESTIMATED_SECTION_HEIGHT: CGFloat = BoldActionSectionHeaderView.estimatedHeight
        static let RATING_GOAL_COUNT: Int = DuffyFramework.Constants.goalReachedCountForRating
        static let RATING_DELAY: Double = 2.0
        static let FOOTER_HEIGHT: CGFloat = 100.0
        static let FOOTER_MARGIN: CGFloat = 16.0
        static let MINIMUM_HEIGHT: CGFloat = 0.1
        static let HOURLY_CELL_MARGIN: CGFloat = 10.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MainTodayTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MainTodayTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: MainHourlyTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MainHourlyTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: MainWeeklySummaryTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MainWeeklySummaryTableViewCell.self))
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(BoldActionSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: BoldActionSectionHeaderView.self))
        tableView.estimatedSectionHeaderHeight = Constants.ESTIMATED_SECTION_HEIGHT
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        subscribeToHealthUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if HealthCache.getGoalReachedCount() >= Constants.RATING_GOAL_COUNT {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.RATING_DELAY) {
                AppRater.askToRate()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToHealthUpdates()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutHeader()
        layoutFooter()
    }
    
    private func layoutHeader() {
        var header: MainTableViewHeader?
        
        if let existingHeader = getHeader() {
            header = existingHeader
        } else {
            header = MainTableViewHeader()
            header?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerWasTapped)))
            tableView.tableHeaderView = header
        }
        
        if let header = header {
            header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: tableView.frame.size.width, height: header.suggestedHeight)
        }
    }
    
    private func layoutFooter() {
        var footer: UIView?
        
        if let existingFooter = tableView.tableFooterView {
            footer = existingFooter
        } else {
            let newFooter = AboutFooterView()
            tableView.tableFooterView = newFooter
            footer = newFooter
        }
        
        if let footer = footer {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: Constants.FOOTER_HEIGHT)
        }
    }
    
    private func getHeader() -> MainTableViewHeader? {
        return tableView.tableHeaderView as? MainTableViewHeader
    }
    
    func refresh() {
        isLoading = true
        goal = HealthCache.dailyGoal()
        
        HealthKitService.getInstance().authorize { [weak self] success in            
            guard success,
                  let weakSelf = self
            else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return
            }
            
            weakSelf.refreshTodayFromHealth()
        }
    }
    
    private func refreshTodayFromHealth() {
        let refreshGroup = DispatchGroup()
        
        //steps
        refreshGroup.enter()
        let startDate = Date().dateByAdding(days: -14)
        let endDate = Date()
        HealthKitService.getInstance().getSteps(from: startDate, to: endDate) { [weak self] result in
            defer {
                refreshGroup.leave()
            }
            
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let stepsCollection):
                weakSelf.steps = stepsCollection
            default:
                break
            }
        }
        
        // hourly steps
        refreshGroup.enter()
        HealthKitService.getInstance().getStepsByHour(for: Date()) { [weak self] result in
            defer {
                refreshGroup.leave()
            }
            
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let steps):
                weakSelf.stepsByHour = steps.stepsByHour
            case .failure(_):
                break
            }
        }
        
        //flights
        refreshGroup.enter()
        HealthKitService.getInstance().getFlightsClimbed(for: Date()) { [weak self] result in
            defer {
                refreshGroup.leave()
            }
            
            guard let weakSelf = self else { return }
            
            switch result {
            case.success((_, let flights)):
                weakSelf.todaysFlights = flights
            default:
                break
            }
        }
        
        //distance
        refreshGroup.enter()
        HealthKitService.getInstance().getDistanceCovered(for: Date()) { [weak self] result in
            defer {
                refreshGroup.leave()
            }
            
            guard let weakSelf = self else { return }
            
            switch result {
            case.success((_, let unit, let distance)):
                weakSelf.todaysDistance = distance
                weakSelf.distanceUnit = unit
            default:
                break
            }
        }
        
        refreshGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.isLoading = false
            weakSelf.tableView?.reloadData()
            weakSelf.maybeRestartObservers()
            weakSelf.maybeAskForCoreMotionPermission()
        }
    }
    
    func maybeAskForCoreMotionPermission() {
        if CoreMotionService.getInstance().shouldAskPermission() {
            CoreMotionService.getInstance().askForPermission()
        }
    }
    
    func maybeRestartObservers() {
        if HealthKitService.getInstance().shouldRestartObservers {
            unsubscribeToHealthUpdates()
            HealthKitService.getInstance().initializeBackgroundQueries()
            subscribeToHealthUpdates()
        }
    }
    
    func subscribeToHealthUpdates() {
        HealthKitService.getInstance().subscribe(to: HKQuantityTypeIdentifier.stepCount) {
            DispatchQueue.main.async { [weak self] in
                guard UIApplication.shared.applicationState == .active else { return }
                self?.refresh()
            }
        }
    }
    
    func unsubscribeToHealthUpdates() {
        HealthKitService.getInstance().unsubscribe(from: HKQuantityTypeIdentifier.stepCount)
    }
    
    private func openHistory() {
        present(ModalNavigationController(rootViewController: HistoryTableViewController()), animated: true, completion: nil)
    }
    
    @objc private func headerWasTapped() {
        refresh()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return MainSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MainSection(rawValue: section) {
        case .today, .hourly:
            return 1
        case .pastWeek:
            guard !isLoading else { return 0 }
            return pastWeekSteps.count > 0 ? pastWeekSteps.count + 1 : 1
        case .none:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch MainSection(rawValue: section) {
        case .hourly:
            return Constants.HOURLY_CELL_MARGIN
        case .today, .pastWeek, .none:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let mainSection = MainSection(rawValue: section),
              let title = mainSection.title,
              let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView
        else {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
        
        header.set(headerText: title, actionText: NSLocalizedString("VIEW HISTORY", comment: ""), action: { [weak self] in self?.openHistory() })
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch MainSection(rawValue: indexPath.section) {
        case .today:
            let todayCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainTodayTableViewCell.self), for: indexPath) as! MainTodayTableViewCell
            todayCell.bind(steps: todaysSteps, flights: todaysFlights, distance: todaysDistance, distanceUnit: distanceUnit)
            return todayCell
        case .hourly:
            let hourlyCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainHourlyTableViewCell.self), for: indexPath) as! MainHourlyTableViewCell
            hourlyCell.bind(stepsByHour: stepsByHour)
            return hourlyCell
        case .pastWeek:
            if indexPath.row == 0 {
                return pastWeekFirstCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
                let currentDate = sortedKeys[indexPath.row - 1];
                if let steps = pastWeekSteps[currentDate] {
                    cell.bind(to: currentDate, steps: steps, goal: goal)
                }
                return cell
            }
        default:
            fatalError("Unexpected section!")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch MainSection(rawValue: section) {
        case .today, .pastWeek:
            return Constants.MINIMUM_HEIGHT
        case .hourly, .none:
            return Constants.FOOTER_MARGIN
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch MainSection(rawValue: section) {
        case .pastWeek:
            return nil
        case .today, .hourly, .none:
            return UIView()
        }
    }

    private func pastWeekFirstCell() -> UITableViewCell {
        guard pastWeekSteps.count > 0 else {
            return NoDataCell()
        }
        
        let average = Steps(pastWeekSteps.values.mean())
        let thisWeeksSum = pastWeekSteps.values.sum()
        let lastWeeksSum = steps.filter({ $0.key < Date().stripTime().dateByAdding(days: -7) }).values.sum()
        var progress = Double.infinity
        
        if lastWeeksSum > 0 && thisWeeksSum > 0 {
            let diff = Int64(thisWeeksSum) - Int64(lastWeeksSum)
            progress = Double(diff) / Double(lastWeeksSum)
        }
        
        let summary = tableView.dequeueReusableCell(withIdentifier: String(describing: MainWeeklySummaryTableViewCell.self), for: IndexPath(row: 0, section: MainSection.pastWeek.rawValue)) as! MainWeeklySummaryTableViewCell
        summary.bind(average: average, progress: progress)
        return summary
    }
    
}

fileprivate enum MainSection: Int, CaseIterable {
    case today, hourly, pastWeek
    
    var title: String? {
        switch self {
        case .pastWeek:
            return NSLocalizedString("Previous Week", comment: "")
        default:
            return nil
        }
    }
}

fileprivate class NoDataCell: UITableViewCell {
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        build()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    private func build() {
        textLabel?.textAlignment = .center
        textLabel?.textColor = Globals.lightGrayColor()
        selectionStyle = .none
        textLabel?.text = NSLocalizedString("No data for the previous week", comment: "")
    }
}
