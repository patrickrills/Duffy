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
    let PAGE_SIZE = 30
    var pastSteps : [Date : Int] = [:]
    var sortedKeys : [Date] = []
    let goal = HealthCache.getStepsDailyGoal()
    var lastDateFetched = Date()
    
    init()
    {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(style: .grouped)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.rowHeight = 44.0
        
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
            footer.frame = CGRect(x: footer.frame.origin.x, y: footer.frame.origin.y, width: tableView.frame.size.width, height: tableView.rowHeight)
        }
    }
    
    @IBAction func loadMorePressed()
    {
        getMoreRows()
    }
    
    func showLoading()
    {
        title = "Getting..."
    }
    
    func hideLoading(_ hasData: Bool)
    {
        title = hasData ? "History" : "No Data"
    }
    
    func getMoreRows()
    {
        showLoading()
        
        let startDate = Calendar.current.date(byAdding: .day, value: -PAGE_SIZE, to: lastDateFetched)
        
        HealthKitService.getInstance().getSteps(startDate!, toEndDate: Date(), onRetrieve: {
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return pastSteps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! PreviousValueTableViewCell
        let currentDate = sortedKeys[indexPath.row];
        if let steps = pastSteps[currentDate]
        {
            cell.bind(toDate: currentDate, steps: steps, goal: goal)
        }
        return cell
    }

}
