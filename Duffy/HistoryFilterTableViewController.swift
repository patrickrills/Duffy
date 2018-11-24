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
        
        let spinner = UIDatePicker(frame: CGRect.zero)
        spinner.tag = DATE_PICKER_TAG
        spinner.datePickerMode = .date
        spinner.maximumDate = Date().addingTimeInterval(-1*60*60*24*7)
        spinner.date = sinceDateFilter
        spinner.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        view.addSubview(spinner)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        if let spinner = view.viewWithTag(DATE_PICKER_TAG)
        {
            //view.frame.size.height - DATE_PICKER_HEIGHT
            spinner.frame = CGRect(x: 0, y: 160, width: view.frame.size.width, height: DATE_PICKER_HEIGHT)
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
        cell.detailTextLabel?.text = Globals.dayFormatter().string(from: sinceDateFilter)
        cell.detailTextLabel?.textColor = Globals.primaryColor()
        cell.accessoryType = .none
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
