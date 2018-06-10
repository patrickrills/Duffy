//
//  WeekViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class WeekViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var tableView: UITableView?
    var pastWeekSteps: [Date : Int]?
    var sortedDates: [Date]?
    let dateFormatter = DateFormatter()
    let numFormatter = NumberFormatter()
    let stepGoal = HealthCache.getStepsDailyGoal()
    
    override func loadView()
    {
        super.loadView()
        
        let appFrameSize = UIScreen.main.bounds.size
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: appFrameSize.width, height: appFrameSize.height), style: .grouped)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: appFrameSize.width, height: appFrameSize.height))
        view?.addSubview(tableView!)
        
        dateFormatter.dateFormat = "eeee, MMM d"
        numFormatter.numberStyle = .decimal
        numFormatter.locale = Locale.current
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        bindTableToWeek()
    }
    
    @IBAction func donePressed()
    {
        dismiss(animated: true, completion: nil)
    }
    
    func showLoading()
    {
        title = "Getting..."
    }
    
    func hideLoading(_ hasData: Bool)
    {
        title = hasData ? "Past Week" : "No Data"
    }
    
    func bindTableToWeek()
    {
        showLoading()
        
        let startDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -7, to: Date(), options: NSCalendar.Options(rawValue: 0))
        
        HealthKitService.getInstance().getSteps(startDate!, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                if let weakSelf = self
                {
                    weakSelf.sortedDates = stepsCollection.keys.sorted(by: {
                        (date1: Date, date2: Date) in
                        return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                    })
                    
                    if (weakSelf.sortedDates!.count == 0) {
                        weakSelf.hideLoading(false)
                        return
                    }
                    
                    weakSelf.pastWeekSteps = stepsCollection
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

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let s = pastWeekSteps
        {
            return s.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if let _ = pastWeekSteps
        {
            return "Steps"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CellValue2")
        
        if let keys = sortedDates, let steps = pastWeekSteps
        {
            let currentKey = keys[indexPath.row]
            if let stepsForDay = steps[currentKey]
            {
                cell.detailTextLabel?.text = dateFormatter.string(from: currentKey)
                cell.detailTextLabel?.textColor = ViewController.primaryColor
                
                if stepGoal > 0, stepsForDay >= stepGoal {
                    cell.textLabel?.text = String(format: "%@ %@", numFormatter.string(from: NSNumber(value: stepsForDay))!, HealthKitService.getInstance().getAdornment(for: stepsForDay))
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
                }
                else {
                    cell.textLabel?.text = numFormatter.string(from: NSNumber(value: stepsForDay))
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
                }
            }
        }
        
        return cell
    }

}
