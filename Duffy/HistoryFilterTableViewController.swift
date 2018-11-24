//
//  HistoryFilterTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/23/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryFilterTableViewController: UITableViewController
{
    let DATE_PICKER_TAG = 987654
    let DATE_PICKER_HEIGHT = CGFloat(200.0)
    
    var sinceDateFilter : Date = Date()
    weak var parentHistoryViewController : HistoryTableViewController? = nil
    
    init(withSelectedDate : Date, fromParent : HistoryTableViewController)
    {
        super.init(style: .grouped)
        sinceDateFilter = withSelectedDate
        parentHistoryViewController = fromParent
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Filter"
        tableView.isScrollEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFilter))
        
        let container = UIView(frame: CGRect.zero)
        container.backgroundColor = UIColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1.0)
        view.addSubview(container)
        
        let spinner = UIDatePicker(frame: CGRect.zero)
        spinner.tag = DATE_PICKER_TAG
        spinner.datePickerMode = .date
        spinner.maximumDate = Date().addingTimeInterval(-1*60*60*24*7)
        spinner.date = sinceDateFilter
        spinner.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        container.addSubview(spinner)
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        if let spinner = view.viewWithTag(DATE_PICKER_TAG)
        {
            var safeArea : CGFloat = 0.0
            if #available(iOS 11.0, *)
            {
                safeArea = view.safeAreaInsets.bottom
            }
            
            let containerHeight = DATE_PICKER_HEIGHT + safeArea
            spinner.superview?.frame = CGRect(x: 0, y: view.frame.size.height - containerHeight + tableView.contentOffset.y, width: view.frame.size.width, height: containerHeight)
            spinner.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: DATE_PICKER_HEIGHT)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Since"
        cell.textLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.text = Globals.fullDateFormatter().string(from: sinceDateFilter)
        cell.detailTextLabel?.textColor = Globals.primaryColor()
        cell.accessoryType = .none
        cell.selectionStyle = .none
        return cell
    }
    
    @IBAction func dateSelected(_ sender : Any?)
    {
        if let spinner = sender as? UIDatePicker
        {
            sinceDateFilter = spinner.date
            tableView.reloadData()
        }
    }
    
    @IBAction func saveFilter()
    {
        if let parent = parentHistoryViewController
        {
            parent.updateDateFilter(sinceDateFilter)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
