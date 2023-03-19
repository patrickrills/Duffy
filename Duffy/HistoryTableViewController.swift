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
    
    //MARK: Properties and State
    
    private let goal = HealthCache.dailyGoal()
    
    private var sort: DetailSortOption = .newestToOldest {
        didSet {
            DetailSortOption.sort(option: sort, dates: &filteredDates)
        }
    }
    
    private var pastSteps : [Date : Steps] = [:]
    private var lastDateInCache: Date {
        return pastSteps.keys.sorted(by: <).first ?? Date().previousDay()
    }
    
    private var filteredDates : [Date] = []
    private var currentFilterDate: Date {
        switch sort {
        case .newestToOldest:
            return filteredDates.last ?? Date()
        case .oldestToNewest:
            return filteredDates.first ?? Date()
        }
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .plain, target: self, action: #selector(changeFilter))
        
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
        
        footer?.isHidden = sort == .oldestToNewest
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
        filteredDates = pastSteps.filter({ $0.key >= startDate }).map(\.key)
        DetailSortOption.sort(option: sort, dates: &filteredDates)
        tableView.reloadData()
        toggleLoading(false)
    }
    
    //MARK: Table view datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return HistorySection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch HistorySection(rawValue: section) {
        case .details:
            return filteredDates.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch HistorySection(rawValue: indexPath.section) {
        case .details:
            return Constants.ROW_HEIGHT
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch HistorySection(rawValue: indexPath.section) {
        case .chart:
            let graphCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTrendChartTableViewCell.self), for: indexPath) as! HistoryTrendChartTableViewCell
            graphCell.bind(to: filteredSteps)
            return graphCell
        case .summary:
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistorySummaryTableViewCell.self), for: indexPath) as! HistorySummaryTableViewCell
            summaryCell.bind(to: filteredSteps)
            return summaryCell
        case .details:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
            let currentDate = filteredDates[indexPath.row];
            if let steps = pastSteps[currentDate] {
                cell.bind(to: currentDate, steps: steps, goal: goal)
            }
            return cell
        default:
            fatalError("Unexpected section")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView,
              let historySection = HistorySection(rawValue: section)
        else {
            return nil
        }
        
        let sectionTitle: String
        var actionTitle: NSAttributedString?
        
        switch historySection {
        case .chart:
            sectionTitle = NSLocalizedString("Trend", comment: "")
            actionTitle = NSAttributedString(string: NSLocalizedString("Options", comment: "Title of a button that changes display options of a chart"))
        case .summary:
            sectionTitle = NSLocalizedString("Summary", comment: "Header of a section that summarizes aggregate data")
        case .details:
            sectionTitle = NSLocalizedString("Details", comment: "")
            actionTitle = sort.displayText()
        }
        
        header.set(headerText: sectionTitle, actionAttributedText: actionTitle, menu: historySection.optionsMenu(handler: self))
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

extension HistoryTableViewController: HistorySectionOptionHandler {
    
    func isDetailSortOptionEnabled(_ option: DetailSortOption) -> Bool {
        return sort == option
    }
    
    func handleDetailSortOption(_ option: DetailSortOption) {
        guard sort != option else { return }
        
        sort = option
        tableView.reloadSections(IndexSet(integer: HistorySection.details.rawValue), with: .automatic)
    }
    
    func handleHistoryTrendChartOption(_ option: HistoryTrendChartOption) {
        option.setEnabled(!option.isEnabled())
        tableView.reloadSections(IndexSet(integer: HistorySection.chart.rawValue), with: .fade)
    }
    
}
