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
        static let ROW_HEIGHT : CGFloat = 44.0
        static let PAGE_SIZE_DAYS: Int = 30
    }
    
    private var pastSteps : [Date : Int] = [:]
    private var sortedKeys : [Date] = []
    private let goal = HealthCache.getStepsDailyGoal()
    private var lastDateFetched: Date {
        return sortedKeys.last ?? Date()
    }
    
    //MARK: Constructors
    
    init() {
        super.init(style: .grouped)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: .grouped)
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
        
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: String(describing: PreviousValueTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: HistoryTrendChartTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: HistoryTrendChartTableViewCell.self))
        clearsSelectionOnViewWillAppear = true
        
        if let footer = HistoryTableViewFooter.createView() {
            footer.loadMoreButton.addTarget(self, action: #selector(loadMorePressed), for: .touchUpInside)
            tableView.tableFooterView = footer
        }
        
        getMoreRows()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let footer = tableView.tableFooterView {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: Constants.ROW_HEIGHT)
        }
    }
    
    //MARK: Event handlers
    
    @IBAction private func changeFilter() {
        navigationController?.pushViewController(HistoryFilterTableViewController(selectedDate: lastDateFetched, onDateSelected: { [weak self] in self?.updateDateFilter($0) }), animated: true)
    }
    
    @IBAction func loadMorePressed() {
        getMoreRows()
    }
    
    private func showLoading() {
        title = NSLocalizedString("Loading...", comment: "")
    }
    
    private func hideLoading(_ hasData: Bool) {
        title = String(format: NSLocalizedString("Since %@", comment: ""), Globals.fullDateFormatter().string(from: lastDateFetched))
    }
    
    private func updateDateFilter(_ filterDate : Date) {
        pastSteps = [:]
        getRows(since: filterDate)
    }
    
    private func getMoreRows() {
        let startDate = Calendar.current.date(byAdding: .day, value: -Constants.PAGE_SIZE_DAYS, to: lastDateFetched)
        getRows(since: startDate!)
    }
    
    private func getRows(since startDate : Date) {
        showLoading()
        
        let lastDateInCache = lastDateFetched
        
        //TODO: Always using Date() as the end date is inefficient:
        //  Update to check is start date is > lastDateFetched and if so just rebuild sorted keys with the sub array
        //  if start date < lastDateFetched only get those days from HK
        
        HealthKitService.getInstance().getSteps(startDate, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
            DispatchQueue.main.async(execute: { [weak self] in
                if let weakSelf = self {
                    stepsCollection.forEach({ (key, value) in weakSelf.pastSteps[key] = value })
                    weakSelf.sortedKeys = weakSelf.pastSteps.keys.sorted(by: >)
                    
                    let fetchedRowCount = stepsCollection.count
                    var hideFooter = fetchedRowCount == 0
                    if (fetchedRowCount > 0) {
                        if (weakSelf.lastDateFetched == lastDateInCache) {
                            hideFooter = true
                        }
                    }
                    
                    if let footer = weakSelf.tableView.tableFooterView as? HistoryTableViewFooter, hideFooter {
                        footer.loadMoreButton.isHidden = true
                    }
                    
                    weakSelf.tableView.reloadData()
                    weakSelf.hideLoading(true)
                }
            })
        },
        onFailure: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.hideLoading(false)
            }
        })
    }
    
    //MARK: Table view datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return pastSteps.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1:
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
            graphCell.bind(to: pastSteps.filter { !Calendar.current.isDate($0.key, inSameDayAs:Date()) })
            return graphCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PreviousValueTableViewCell.self), for: indexPath) as! PreviousValueTableViewCell
            let currentDate = sortedKeys[indexPath.row];
            if let steps = pastSteps[currentDate] {
                cell.bind(toDate: currentDate, steps: steps, goal: goal)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Trend", comment: "")
        case 1:
            return NSLocalizedString("Details", comment: "")
        default:
            return nil
        }
    }
}
