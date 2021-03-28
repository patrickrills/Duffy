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
    private var todaysSteps: Steps = 0
    private var todaysFlights: FlightsClimbed = 0
    private var todaysDistance: DistanceTravelled = 0
    private var distanceUnit: LengthFormatter.Unit = .mile
    private var sortedKeys: [Date] = []
    private var pastSteps: [Date : Steps] = [:] {
        didSet {
            sortedKeys = pastSteps.keys.sorted(by: >)
        }
    }
    
    private var isLoading: Bool = false
    //TODO: Loading state
//    {
//        didSet {
//            getHeader()?.toggleLoading(isLoading: isLoading)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MainTodayTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: MainTodayTableViewCell.self))
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(MainSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: MainSectionHeaderView.self))
        tableView.estimatedSectionHeaderHeight = MainSectionHeaderView.estimatedHeight
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        subscribeToHealthUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if HealthCache.getGoalReachedCount() >= Constants.goalReachedCountForRating {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
        
//        if tableView.tableHeaderView == nil {
//            if let header = TodayHeaderView.createView() {
//                header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: heightForHeader())
//                tableView.tableHeaderView = header
//            }
//        }
        
        if tableView.tableFooterView == nil {
            let footer = AboutFooterView()
            footer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 72.0)
            footer.addTarget(self, action: #selector(openAbout))
            tableView.tableFooterView = footer
        }
    }
    
//    private func getHeader() -> TodayHeaderView? {
//        return tableView.tableHeaderView as? TodayHeaderView
//    }
    
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
        let startDate = Date().dateByAdding(days: -7)
        let endDate = Date()
        HealthKitService.getInstance().getSteps(from: startDate, to: endDate) { [weak self] result in
            defer {
                refreshGroup.leave()
            }
            
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let stepsCollection):
                weakSelf.pastSteps = stepsCollection.filter { !$0.key.isToday() }
                weakSelf.todaysSteps = stepsCollection.first(where: { $0.key.isToday() })?.value ?? 0
            default:
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
    
    @objc private func openAbout() {
        present(ModalNavigationController(rootViewController: AboutTableViewController()), animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return MainSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MainSection(rawValue: section) {
        case .pastWeek:
            guard !isLoading else { return 0 }
            return pastSteps.count > 0 ? pastSteps.count : 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard MainSection(rawValue: section) == .pastWeek,
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: MainSectionHeaderView.self)) as? MainSectionHeaderView
        else {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }

        header.setOpenHistory { [weak self] in self?.openHistory() }
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch MainSection(rawValue: indexPath.section) {
        case .today:
            let todayCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainTodayTableViewCell.self), for: indexPath) as! MainTodayTableViewCell
            todayCell.bind(steps: todaysSteps, flights: todaysFlights, distance: todaysDistance, distanceUnit: distanceUnit)
            return todayCell
        case .pastWeek:
            if indexPath.row == 0 && pastSteps.count == 0 {
                let plainCell = UITableViewCell(style: .default, reuseIdentifier: nil)
                plainCell.textLabel?.textAlignment = .center
                plainCell.textLabel?.textColor = Globals.lightGrayColor()
                plainCell.selectionStyle = .none
                plainCell.textLabel?.text = NSLocalizedString("No data for the previous week", comment: "")
                return plainCell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
                let currentDate = sortedKeys[indexPath.row];
                if let steps = pastSteps[currentDate] {
                    cell.bind(to: currentDate, steps: steps, goal: goal)
                }
                return cell
            }
        default:
            fatalError("Unexpected section!")
        }
    }
}

fileprivate enum MainSection: Int, CaseIterable {
    case today, pastWeek
}
