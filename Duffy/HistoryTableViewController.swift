//
//  WeekViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistoryTableViewController: UITableViewController
{
    let CELL_ID = "PreviousValueTableViewCell"
    let CHART_CELL_ID = "HistoryTrendChartTableViewCell"
    let DETAILS_ROW_HEIGHT : CGFloat = 44.0
    let PAGE_SIZE = 30
    var pastSteps : [Date : Int] = [:]
    var sortedKeys : [Date] = []
    let goal = HealthCache.getStepsDailyGoal()
    var lastDateFetched = Date()
    
    init()
    {
        super.init(style: .grouped)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(style: .grouped)
        self.modalPresentationStyle = .fullScreen
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Filter", comment: ""), style: .plain, target: self, action: #selector(changeFilter))
        
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.register(UINib(nibName: CHART_CELL_ID, bundle: Bundle.main), forCellReuseIdentifier: CHART_CELL_ID)
        clearsSelectionOnViewWillAppear = true
        
        let footer = HistoryTableViewFooter.createView()
        footer?.loadMoreButton?.addTarget(self, action: #selector(loadMorePressed), for: .touchUpInside)
        tableView.tableFooterView = footer
        
        getMoreRows()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        if let footer = tableView.tableFooterView
        {
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: DETAILS_ROW_HEIGHT)
        }
    }
    
    @IBAction func loadMorePressed()
    {
        getMoreRows()
    }
    
    func showLoading()
    {
        title = NSLocalizedString("Loading...", comment: "")
    }
    
    func hideLoading(_ hasData: Bool)
    {
        title = String(format: NSLocalizedString("Since %@", comment: ""), Globals.fullDateFormatter().string(from: lastDateFetched))
    }
    
    func updateDateFilter(_ filterDate : Date)
    {
        pastSteps = [:]
        getRowsSince(filterDate)
    }
    
    func getMoreRows()
    {
        let startDate = Calendar.current.date(byAdding: .day, value: -PAGE_SIZE, to: lastDateFetched)
        getRowsSince(startDate!)
    }
    
    func getRowsSince(_ startDate : Date)
    {
        showLoading()
        
        HealthKitService.getInstance().getSteps(startDate, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                if let weakSelf = self
                {
                    stepsCollection.forEach({ (key, value) in weakSelf.pastSteps[key] = value })
                    weakSelf.sortedKeys = weakSelf.pastSteps.keys.sorted(by: >)
                    
                    let fetchedRowCount = stepsCollection.count
                    var hideFooter = fetchedRowCount == 0
                    if (fetchedRowCount > 0)
                    {
                        let lastDateInCache = weakSelf.sortedKeys[weakSelf.sortedKeys.count - 1];
                        if (weakSelf.lastDateFetched == lastDateInCache)
                        {
                            hideFooter = true
                        }
                        else
                        {
                            weakSelf.lastDateFetched = lastDateInCache
                        }
                    }
                    
                    if let footer = weakSelf.tableView?.tableFooterView as? HistoryTableViewFooter, hideFooter
                    {
                        footer.loadMoreButton?.isHidden = true
                    }
                    
                    weakSelf.tableView?.reloadData()
                    weakSelf.hideLoading(true)
                }
            })
        },
            onFailure: {
            [weak self] (err: Error?) in
                DispatchQueue.main.async {
                    self?.hideLoading(false)
                }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 1:
                return pastSteps.count
            
            default:
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section
        {
            case 1:
                return DETAILS_ROW_HEIGHT
            
            default:
                return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section
        {
            case 0:
                return 265.0
            
            default:
                return DETAILS_ROW_HEIGHT
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
            case 0:
                let graphCell = tableView.dequeueReusableCell(withIdentifier: CHART_CELL_ID, for: indexPath) as! HistoryTrendChartTableViewCell
                graphCell.bind(toStepsByDay: pastSteps.filter { !Calendar.current.isDate($0.key, inSameDayAs:Date()) })
                return graphCell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! PreviousValueTableViewCell
                let currentDate = sortedKeys[indexPath.row];
                if let steps = pastSteps[currentDate]
                {
                    cell.bind(toDate: currentDate, steps: steps, goal: goal)
                }
                return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
            case 0:
                return NSLocalizedString("Trend", comment: "")
            case 1:
                return NSLocalizedString("Details", comment: "")
            default:
                return nil
        }
    }
    
    @IBAction fileprivate func changeFilter()
    {
        navigationController?.pushViewController(HistoryFilterTableViewController(withSelectedDate: lastDateFetched, fromParent: self), animated: true)
    }
}
