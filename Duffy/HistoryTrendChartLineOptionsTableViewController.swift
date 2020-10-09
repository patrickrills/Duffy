//
//  HistoryTrendChartLineOptionsTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTrendChartLineOptionsTableViewController: UITableViewController {

    private let lineOptions: [HistoryTrendChartLineOption] = HistoryTrendChartLineOption.allCases
    
    init() {
        super.init(style: .grouped)
        
        title = "Show Lines" //TODO: Translate to Japanese
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(navigateBack))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navigateBack))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("xib is not used for HistoryTrendChartOptionsTableViewController")
    }
    
    @objc private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lineOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let option = lineOptions[indexPath.row]
        cell.textLabel?.text = option.displayName()
        cell.accessoryType = option.isEnabled() ? .checkmark : .none
        cell.tintColor = Globals.primaryColor()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = lineOptions[indexPath.row]
        option.setEnabled()
        tableView.reloadData()
        DispatchQueue.main.async {
            self.navigateBack()
        }
    }
}
