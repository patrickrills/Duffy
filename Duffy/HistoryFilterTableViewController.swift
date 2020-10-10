//
//  HistoryFilterTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/23/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryFilterTableViewController: UITableViewController {
    
    private var sinceDateFilter : Date = Date()
    private let onDateSelected: (Date) -> ()
    
    //MARK: Constructors
    
    init(selectedDate: Date, onDateSelected: @escaping (Date) -> ()) {
        self.sinceDateFilter = selectedDate
        self.onDateSelected = onDateSelected
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("HistoryFilterTableViewController does not use xib")
    }
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Filter", comment: "")
        tableView.isScrollEnabled = false
        tableView.sectionHeaderHeight = 16.0
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(saveFilter))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFilter))
        }
        
        addDatePicker()
    }
    
    private func addDatePicker() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(named: "SpinnerBackgroundColor")
        tableView.addSubview(container)
        
        let spinner = UIDatePicker()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.datePickerMode = .date
        spinner.maximumDate = Date().addingTimeInterval(-1*60*60*24*7)
        spinner.date = sinceDateFilter
        spinner.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        container.addSubview(spinner)
        
        if #available(iOS 14.0, *) {
            spinner.preferredDatePickerStyle = .wheels
        }
        
        let safeAreaSpacer = UIView()
        safeAreaSpacer.translatesAutoresizingMaskIntoConstraints = false
        safeAreaSpacer.backgroundColor = container.backgroundColor
        tableView.addSubview(safeAreaSpacer)
        
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: tableView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 200.0),
            spinner.topAnchor.constraint(equalTo: container.topAnchor),
            spinner.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            spinner.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            safeAreaSpacer.bottomAnchor.constraint(equalTo: tableView.frameLayoutGuide.bottomAnchor),
            safeAreaSpacer.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor),
            safeAreaSpacer.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor),
            safeAreaSpacer.topAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    //MARK: Event handlers
    
    @IBAction func dateSelected(_ sender : Any?) {
        if let spinner = sender as? UIDatePicker {
            sinceDateFilter = spinner.date
            tableView.reloadData()
        }
    }
    
    @IBAction func saveFilter() {
        onDateSelected(sinceDateFilter)
        navigationController?.popViewController(animated: true)
    }

    //MARK: Table view datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
