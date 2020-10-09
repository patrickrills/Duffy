//
//  WeekViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistoryTableViewController: UITableViewController {
    private enum Constants {
        static let ROW_HEIGHT : CGFloat = PreviousValueTableViewCell.rowHeight
        static let PAGE_SIZE_DAYS: Int = 30
    }
    
    private let goal = HealthCache.dailyGoal()
    
    private var pastSteps : [Date : Steps] = [:]
    private var lastDateInCache: Date {
        return pastSteps.keys.sorted(by: <).first ?? Date()
    }
    
    private var filteredDates : [Date] = []
    private var currentFilterDate: Date {
        return filteredDates.last ?? Date()
    }
    
    //MARK: Constructors
    
    init() {
        super.init(style: HistoryTableViewController.tableStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: HistoryTableViewController.tableStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    private class func tableStyle() -> UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        }
        
        return .grouped
    }
    
    //MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(changeFilter))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: ""), style: .plain, target: self, action: #selector(changeFilter))
        }
        
        tableView.estimatedSectionHeaderHeight = HistorySectionHeaderView.estimatedHeight
        tableView.register(HistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: HistorySectionHeaderView.self))
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: HistoryTrendChartTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: HistoryTrendChartTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: HistorySummaryTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: HistorySummaryTableViewCell.self))
        clearsSelectionOnViewWillAppear = true
        
        getNextPage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutFooter()
    }
    
    private func layoutFooter() {
        var footer: UIView?
        
        if let existingFooter = tableView.tableFooterView {
            footer = existingFooter
        } else if let newFooter = HistoryTableViewFooter.createView() {
            newFooter.loadMoreButton.addTarget(self, action: #selector(loadMorePressed), for: .touchUpInside)
            tableView.tableFooterView = newFooter
            footer = newFooter
        }
        
        if let footer = footer {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: Constants.ROW_HEIGHT)
        }
    }
    
    //MARK: Event handlers
    
    @IBAction private func changeFilter() {
        navigationController?.pushViewController(HistoryFilterTableViewController(selectedDate: currentFilterDate, onDateSelected: { [weak self] in self?.updateDateFilter($0) }), animated: true)
    }
    
    @IBAction func loadMorePressed() {
        getNextPage()
    }
    
    private func toggleLoading(_ isLoading: Bool) {
        title = isLoading
            ? NSLocalizedString("Loading...", comment: "")
            : String(format: NSLocalizedString("Since %@", comment: ""), Globals.fullDateFormatter().string(from: currentFilterDate))
                    
    }
    
    private func updateDateFilter(_ filterDate : Date) {
        filterSteps(since: filterDate)
    }
    
    private func getNextPage() {
        let startDate = Calendar.current.date(byAdding: .day, value: -Constants.PAGE_SIZE_DAYS, to: currentFilterDate)
        filterSteps(since: startDate!)
    }
    
    private func filterSteps(since startDate : Date) {
        toggleLoading(true)
        
        if startDate >= lastDateInCache {
            refresh(for: startDate)
        } else {
            let previousLastCacheDate = lastDateInCache
            
            HealthKitService.getInstance().getSteps(from: startDate, to: lastDateInCache) { [weak self] result in
                switch result {
                case .success(let stepsCollection):
                    DispatchQueue.main.async {
                        if let weakSelf = self {
                            weakSelf.pastSteps.merge(stepsCollection, uniquingKeysWith: { $1 })
                            weakSelf.refresh(for: startDate)
                            
                            let fetchedRowCount = stepsCollection.count
                            let hideFooter = fetchedRowCount == 0 || weakSelf.lastDateInCache == previousLastCacheDate

                            if let footer = weakSelf.tableView.tableFooterView as? HistoryTableViewFooter, hideFooter {
                                footer.loadMoreButton.isHidden = true
                            }
                        }
                    }
                case .failure(_):
                    self?.toggleLoading(false)
                }
            }
        }
    }
    
    private func refresh(for startDate: Date) {
        filteredDates = pastSteps.filter({ $0.key >= startDate }).map(\.key).sorted(by: >)
        tableView.reloadData()
        toggleLoading(false)
    }
    
    private func showChartOptions() {
        present(ModalNavigationController(rootViewController: HistoryTrendChartOptionsTableViewController(), doneButtonSystemImageName: "checkmark.circle", onDismiss: { [weak self] in self?.tableView.reloadSections(IndexSet(integer: 0), with: .fade) }), animated: true, completion: nil)
    }
    
    //MARK: Table view datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return filteredDates.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return Constants.ROW_HEIGHT
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section {
        case 0:
            let graphCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTrendChartTableViewCell.self), for: indexPath) as! HistoryTrendChartTableViewCell
            graphCell.bind(to: pastSteps.filter { filteredDates.contains($0.key) && !$0.key.isToday() })
            return graphCell
        case 1:
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistorySummaryTableViewCell.self), for: indexPath) as! HistorySummaryTableViewCell
            summaryCell.bind(to: pastSteps.filter { filteredDates.contains($0.key) && !$0.key.isToday() })
            return summaryCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
            let currentDate = filteredDates[indexPath.row];
            if let steps = pastSteps[currentDate] {
                cell.bind(to: currentDate, steps: steps, goal: goal)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HistorySectionHeaderView.self)) as? HistorySectionHeaderView else { return nil }
        
        let sectionTitle: String
        let actionTitle: String = "Options" //TODO: Japanese translation of "Options"
        var action: (() -> ())?
        
        switch section {
        case 0:
            sectionTitle = NSLocalizedString("Trend", comment: "")
            action = { [weak self] in self?.showChartOptions() }
        case 1:
            sectionTitle = "Summary" //TODO: Japanese translation of "Summary"
        case 2:
            sectionTitle = NSLocalizedString("Details", comment: "")
        default:
            return nil
        }
        
        header.set(headerText: sectionTitle, actionText: (action != nil ? actionTitle : nil), action: action)
        return header
    }
}
