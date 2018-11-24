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
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(style: .grouped)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 2:
                return pastSteps.count
            
            default:
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section
        {
            case 2:
                return DETAILS_ROW_HEIGHT
            
            default:
                return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
            case 0:
                let filterCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                filterCell.textLabel?.text = "Since"
                filterCell.detailTextLabel?.text = Globals.fullDateFormatter().string(from: lastDateFetched)
                filterCell.detailTextLabel?.textColor = Globals.secondaryColor()
                filterCell.accessoryType = .disclosureIndicator
                return filterCell
         
            case 1:
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
            case 1:
                return "Trend"
            case 2:
                return "Details"
            default:
                return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            navigationController?.pushViewController(HistoryFilterTableViewController(), animated: true)
        }
    }
}
