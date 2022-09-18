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
        
        title = NSLocalizedString("Show Lines", comment: "Title of a screen where user selects which lines are shown on a graph")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"), style: .plain, target: self, action: #selector(navigateBack))
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
        cell.tintColor = Globals.secondaryColor()
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
