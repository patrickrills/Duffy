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
        static let ROW_HEIGHT: CGFloat = PreviousValueTableViewCell.rowHeight
        static let PAGE_SIZE_DAYS: Int = 30
        static let FOOTER_HEIGHT: CGFloat = 80.0
        static let FOOTER_MARGIN: CGFloat = 16.0
        static let MINIMUM_HEIGHT: CGFloat = 0.1
    }
    
    private let goal = HealthCache.dailyGoal()
    private let defaultEndDate = Date()
    
    private var pastSteps : [Date : Steps] = [:]
    private var lastDateInCache: Date {
        return pastSteps.keys.sorted(by: <).first ?? defaultEndDate
    }
    
    private var filteredDates : [Date] = []
    private var currentFilterDate: Date {
        return filteredDates.last ?? defaultEndDate
    }
    
    private var filteredSteps: [Date : Steps] {
        return pastSteps.filter({ filteredDates.contains($0.key) })
    }
    
    //MARK: Constructors
    
    init() {
        super.init(style: Globals.tableViewStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: Globals.tableViewStyle())
        self.modalPresentationStyle = .fullScreen
    }
    
    //MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(changeFilter))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: ""), style: .plain, target: self, action: #selector(changeFilter))
        }
        
        tableView.estimatedSectionHeaderHeight = BoldActionSectionHeaderView.estimatedHeight
        tableView.register(BoldActionSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: BoldActionSectionHeaderView.self))
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
        } else {
            let newFooter = HistoryTableViewFooter()
            newFooter.addTarget(self, action: #selector(loadMorePressed))
            tableView.tableFooterView = newFooter
            footer = newFooter
        }
        
        if let footer = footer {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: Constants.FOOTER_HEIGHT)
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
        let startDate = currentFilterDate.dateByAdding(days: -Constants.PAGE_SIZE_DAYS)
        filterSteps(since: startDate)
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

                            if let footer = weakSelf.tableView.tableFooterView as? HistoryTableViewFooter {
                                footer.isButtonHidden = hideFooter
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
            graphCell.bind(to: filteredSteps)
            return graphCell
        case 1:
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistorySummaryTableViewCell.self), for: indexPath) as! HistorySummaryTableViewCell
            summaryCell.bind(to: filteredSteps)
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
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView else { return nil }
        
        let sectionTitle: String
        let actionTitle: String = NSLocalizedString("Options", comment: "Title of a button that changes display options of a chart")
        var action: (() -> ())?
        
        switch section {
        case 0:
            sectionTitle = NSLocalizedString("Trend", comment: "")
            action = { [weak self] in self?.showChartOptions() }
        case 1:
            sectionTitle = NSLocalizedString("Summary", comment: "Header of a section that summarizes aggregate data")
        case 2:
            sectionTitle = NSLocalizedString("Details", comment: "")
        default:
            return nil
        }
        
        header.set(headerText: sectionTitle, actionText: (action != nil ? actionTitle : nil), action: action)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == numberOfSections(in: tableView) - 1 else {
            return Constants.FOOTER_MARGIN
        }
        
        return Constants.MINIMUM_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == numberOfSections(in: tableView) - 1 else {
            return nil
        }
        
        return UIView()
    }
}
