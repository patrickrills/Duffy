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

class MainTableViewController: UITableViewController
{
    var stepsByDay : [Date : Steps] = [:]
    var sortedKeys : [Date] = []
    var goal : Steps = 0
    var isLoading : Bool = false {
        didSet {
            getHeader()?.toggleLoading(isLoading: isLoading)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(MainSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: MainSectionHeaderView.self))
        tableView.estimatedSectionHeaderHeight = MainSectionHeaderView.estimatedHeight
        tableView.rowHeight = PreviousValueTableViewCell.rowHeight
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
    
    func heightForHeader() -> CGFloat {
        let safeArea : CGFloat = view.safeAreaInsets.top        
        let availableRealEstate = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.size.height - safeArea
        let amountOfTableToShow = tableView.estimatedSectionHeaderHeight + (tableView.rowHeight * 1.1);
        return ceil(availableRealEstate - amountOfTableToShow)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            if let header = TodayHeaderView.createView() {
                header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: heightForHeader())
                tableView.tableHeaderView = header
            }
        }
        
        if tableView.tableFooterView == nil {
            if let footer = AboutFooterView.createView() {
                footer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120.0)
                footer.aboutButton?.addTarget(self, action: #selector(openAbout), for: .touchUpInside)
                tableView.tableFooterView = footer
            }
        }
        
        if let aboutFooter = tableView.tableFooterView as? AboutFooterView {
            aboutFooter.separatorIsVisible = stepsByDay.count > 0
        }
    }
    
    private func getHeader() -> TodayHeaderView? {
        return tableView.tableHeaderView as? TodayHeaderView
    }
    
    func refresh() {
        isLoading = true
        
        HealthKitService.getInstance().authorize { [weak self] success in
            if success {
                let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                HealthKitService.getInstance().getSteps(from: startDate, to: endDate) { result in
                    switch result {
                    case .success(let stepsCollection):
                        DispatchQueue.main.async { [weak self] in
                            if let weakSelf = self {
                                weakSelf.isLoading = false
                                weakSelf.goal = HealthCache.dailyGoal()
                                weakSelf.stepsByDay = stepsCollection
                                weakSelf.sortedKeys = stepsCollection.keys.sorted(by: >)
                                weakSelf.tableView?.separatorStyle = stepsCollection.count == 0 ? .none : .singleLine
                                weakSelf.tableView?.reloadData()
                                weakSelf.getHeader()?.refresh()
                                weakSelf.maybeRestartObservers()
                                weakSelf.maybeAskForCoreMotionPermission()
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            self?.isLoading = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
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
        HealthKitService.getInstance().subscribe(to: HKQuantityTypeIdentifier.stepCount, on: {
            DispatchQueue.main.async {
                [weak self] in
                
                if UIApplication.shared.applicationState != .active {
                    return
                }
                
                self?.refresh()
            }
        })
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isLoading else { return 0 }
        return stepsByDay.count > 0 ? stepsByDay.count : 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: MainSectionHeaderView.self)) as? MainSectionHeaderView else { return nil }
        header.setOpenHistory { [weak self] in self?.openHistory() }
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && stepsByDay.count == 0 {
            let plainCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            plainCell.textLabel?.textAlignment = .center
            plainCell.textLabel?.textColor = Globals.lightGrayColor()
            plainCell.selectionStyle = .none
            plainCell.textLabel?.text = NSLocalizedString("No data for the previous week", comment: "")
            return plainCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
            let currentDate = sortedKeys[indexPath.row];
            if let steps = stepsByDay[currentDate] {
                cell.bind(to: currentDate, steps: steps, goal: goal)
            }
            return cell
        }
    }
}
