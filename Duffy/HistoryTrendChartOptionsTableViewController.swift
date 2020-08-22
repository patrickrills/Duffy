//
//  HistoryTrendChartOptionsTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/22/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTrendChartOptionsTableViewController: UITableViewController {

    private let settings = HistoryTrendChartOption.allCases
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("xib is not used for HistoryTrendChartOptionsTableViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Options" //TODO: Japanese translation of Options
        tableView.sectionHeaderHeight = 16.0
        tableView.register(HistoryTrendChartOptionTableViewCell.self, forCellReuseIdentifier: String(describing: HistoryTrendChartOptionTableViewCell.self))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTrendChartOptionTableViewCell.self), for: indexPath) as? HistoryTrendChartOptionTableViewCell else { return UITableViewCell() }
        cell.setting = settings[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Add some spacing between the navigation title and the first row (combined with sectionHeaderHeight)
        return UIView()
    }
}

fileprivate class HistoryTrendChartOptionTableViewCell: UITableViewCell {
    
    private weak var settingSwitch: UISwitch?
    
    var setting: HistoryTrendChartOption? {
        didSet {
            if let setting = setting {
                textLabel?.text = setting.displayName()
                settingSwitch?.isOn = setting.isEnabled()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionStyle = .none
        if settingSwitch == nil {
            let control = UISwitch()
            control.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
            accessoryView = control
            settingSwitch = control
        }
        
        setting = nil
        settingSwitch?.isOn = false
    }
    
    @objc func settingChanged() {
        guard let setting = setting, let settingSwitch = settingSwitch else { return }
        setting.setEnabled(settingSwitch.isOn)
    }
}
