//
//  MainTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 6/23/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class MainTableViewController: UITableViewController
{
    let CELL_ID = "PreviousValueTableViewCell"
    let SECTION_ID = "PreviousSectionHeaderView"
    var isLoading : Bool = false
    var stepsByDay : [Date : Int] = [:]
    var sortedKeys : [Date] = []
    var goal : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.register(PreviousValueTableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.register(PreviousSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SECTION_ID)
        tableView.sectionHeaderHeight = 44.0
        tableView.rowHeight = 44.0
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func heightForHeader() -> CGFloat
    {
        var safeArea : CGFloat = 0.0
        if #available(iOS 11.0, *)
        {
             safeArea = view.safeAreaInsets.top
        }
        
        let availableRealEstate = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.size.height - safeArea
        let amountOfTableToShow = tableView.sectionHeaderHeight + (tableView.rowHeight * 1.1);
        return availableRealEstate - amountOfTableToShow
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        if (tableView.tableHeaderView == nil)
        {
            if let header = TodayHeaderView.createView()
            {
                header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: heightForHeader())
                tableView.tableHeaderView = header
            }
        }
    }
    
    private func showLoading()
    {
        if let header = getHeader()
        {
            header.toggleLoading(isLoading: true)
        }
    }
    
    private func hideLoading()
    {
        if let header = getHeader()
        {
            header.toggleLoading(isLoading: false)
        }
    }
    
    private func getHeader() -> TodayHeaderView?
    {
        return tableView?.tableHeaderView as? TodayHeaderView
    }
    
    func refresh()
    {
        isLoading = true
        showLoading()
        
        HealthKitService.getInstance().authorizeForAllData({
            
            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())
            let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            
            HealthKitService.getInstance().getSteps(startDate!, toEndDate: endDate!, onRetrieve: {
                (stepsCollection: [Date : Int]) in
                
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    if let weakSelf = self
                    {
                        weakSelf.isLoading = false
                        weakSelf.goal = HealthCache.getStepsDailyGoal()
                        weakSelf.stepsByDay = stepsCollection
                        weakSelf.sortedKeys = stepsCollection.keys.sorted(by: >)
                        weakSelf.tableView?.separatorStyle = stepsCollection.count == 0 ? .none : .singleLine
                        weakSelf.tableView?.reloadData()
                        
                        if let header = weakSelf.getHeader()
                        {
                            header.refresh()
                        }
                        
                        weakSelf.hideLoading()
                    }
                })
            },
            onFailure: {
                [weak self] (err: Error?) in
                    DispatchQueue.main.async {
                        self?.hideLoading()
                        self?.isLoading = false
                }
            })
        }, onFailure: {
            self.isLoading = false
        })
    }
    
    private func openHistory()
    {
        let weekVC = HistoryTableViewController()
        let modalNav = UINavigationController(rootViewController: weekVC)
        modalNav.navigationBar.tintColor = Globals.secondaryColor()
        present(modalNav, animated: true, completion: nil)
    }
    
    @IBAction private func openHistoryPressed()
    {
        openHistory()
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (isLoading)
        {
            return 0
        }
        
        return (stepsByDay.count == 0 ? 1 : stepsByDay.count + 1)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SECTION_ID) as? PreviousSectionHeaderView
            {
                header.button?.addTarget(self, action: #selector(openHistoryPressed), for: .touchUpInside)
                return header
            }
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.row == 0 && stepsByDay.count == 0)
        {
            let plainCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            plainCell.textLabel?.textAlignment = .center
            plainCell.textLabel?.textColor = UIColor.lightGray
            plainCell.selectionStyle = .none
            plainCell.textLabel?.text = "No data for the previous week"
            return plainCell
        }
        else if (indexPath.row == stepsByDay.count)
        {
            let buttonCell = UITableViewCell(style: .default, reuseIdentifier: nil)
            buttonCell.textLabel?.textAlignment = .center
            buttonCell.textLabel?.textColor = Globals.secondaryColor()
            buttonCell.textLabel?.text = "View More History"
            return buttonCell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! PreviousValueTableViewCell
            let currentDate = sortedKeys[indexPath.row];
            if let steps = stepsByDay[currentDate]
            {
                cell.bind(toDate: currentDate, steps: steps, goal: goal)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.row == stepsByDay.count)
        {
            openHistory()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
