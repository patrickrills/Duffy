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
    let CONTAINER_TAG = 987655
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
        
        title = NSLocalizedString("Filter", comment: "")
        tableView.isScrollEnabled = false
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(saveFilter))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFilter))
        }
        
        let container = UIView(frame: CGRect.zero)
        container.tag = CONTAINER_TAG
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
            let safeArea : CGFloat = view.safeAreaInsets.bottom
            let containerHeight = DATE_PICKER_HEIGHT + safeArea
            spinner.superview?.frame = CGRect(x: 0, y: view.frame.size.height - containerHeight + tableView.contentOffset.y, width: view.frame.size.width, height: containerHeight)
            spinner.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: DATE_PICKER_HEIGHT)
        }
        
        if let container = view.viewWithTag(CONTAINER_TAG) {
            container.backgroundColor = UIColor(named: "SpinnerBackgroundColor")
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
        cell.textLabel?.text = NSLocalizedString("Since", comment: "")
        cell.detailTextLabel?.text = Globals.fullDateFormatter().string(from: sinceDateFilter)
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        if #available(iOS 13.0, *) {
            cell.detailTextLabel?.textColor = .label
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.detailTextLabel?.textColor = .black
            cell.textLabel?.textColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        }
        
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
