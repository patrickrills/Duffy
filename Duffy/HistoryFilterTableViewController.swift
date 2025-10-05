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
    
    //MARK: Layout mode and constants
    
    private enum DateMode {
        case spinner, calendar
        
        func backgroundColor() -> UIColor {
            if self == .calendar {
                return .secondarySystemGroupedBackground
            }
            
            return UIColor(named: "SpinnerBackgroundColor")!
        }
        
        func pickerHeight() -> CGFloat {
            switch self {
            case .spinner:
                return 200.0
            case .calendar:
                return 352.0
            }
        }
        
        func horizontalMargin() -> CGFloat {
            switch self {
            case .spinner:
                return 0.0
            case .calendar:
                return 16.0
            }
        }
        
        static func mode() -> DateMode {
            guard !Globals.isNarrowPhone() else { return .spinner }
            return .calendar
        }
    }
    
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
        
        title = NSLocalizedString("Select Date", comment: "")
        tableView.isScrollEnabled = false
        tableView.sectionHeaderHeight = 16.0
        
        let saveSystemImage: String
        if #available(iOS 26.0, *) {
            saveSystemImage = "checkmark"
        } else {
            saveSystemImage = "checkmark.circle.fill"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.saveBarButtonItem(with: saveSystemImage, target: self, action: #selector(saveFilter))
                
        addDatePicker()
    }
    
    private func addDatePicker() {
        let mode = DateMode.mode()
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = mode.backgroundColor()
        tableView.addSubview(container)
        
        let spinner = UIDatePicker()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.datePickerMode = .date
        spinner.maximumDate = Date().addingTimeInterval(-1*60*60*24*7)
        spinner.date = sinceDateFilter
        spinner.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        spinner.tintColor = Globals.secondaryColor()
        container.addSubview(spinner)
        
        let safeAreaSpacer = UIView()
        safeAreaSpacer.translatesAutoresizingMaskIntoConstraints = false
        safeAreaSpacer.backgroundColor = container.backgroundColor
        tableView.addSubview(safeAreaSpacer)
        
        spinner.preferredDatePickerStyle = mode == .calendar ? .inline : .wheels
        
        NSLayoutConstraint.activate([
            container.bottomAnchor.constraint(equalTo: tableView.layoutMarginsGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: tableView.frameLayoutGuide.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: mode.pickerHeight()),
            spinner.topAnchor.constraint(equalTo: container.topAnchor),
            spinner.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: mode.horizontalMargin()),
            spinner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -mode.horizontalMargin()),
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
        
        cell.detailTextLabel?.textColor = .label
        cell.textLabel?.textColor = .secondaryLabel
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let numberOfDays = sinceDateFilter.differenceInDays(from: Date())
        return String.localizedStringWithFormat(NSLocalizedString("Last %d days", comment: "Placeholder is a number of days"), numberOfDays)
    }
}
