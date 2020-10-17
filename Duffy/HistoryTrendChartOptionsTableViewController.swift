//
//  HistoryTrendChartOptionsTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/22/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTrendChartOptionsTableViewController: UITableViewController {

    private let indicators: [HistoryTrendChartOption] = [.goalIndicator, .averageIndicator]
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("xib is not used for HistoryTrendChartOptionsTableViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Graph Options", comment: "Title of screen that allows the user to change display options of a chart/graph")
        clearsSelectionOnViewWillAppear = true
        tableView.register(HistoryTrendChartOptionTableViewCell.self, forCellReuseIdentifier: String(describing: HistoryTrendChartOptionTableViewCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return indicators.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0
                ? NSLocalizedString("Data", comment: "Title of section of options changing how to display your data on a chart/graph")
                : NSLocalizedString("Indicators", comment: "Title of section of options changing which markers are shown on a chart/graph")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let lineCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            lineCell.textLabel?.text = NSLocalizedString("Lines", comment: "Option to change how the lines on a chart are drawn")
            lineCell.detailTextLabel?.text = HistoryTrendChartLineOption.currentValue().displayName()
            lineCell.accessoryType = .disclosureIndicator
            return lineCell
        } else {
            guard let indicatorCell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryTrendChartOptionTableViewCell.self), for: indexPath) as? HistoryTrendChartOptionTableViewCell else { return UITableViewCell() }
            indicatorCell.setting = indicators[indexPath.row]
            return indicatorCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            navigationController?.pushViewController(HistoryTrendChartLineOptionsTableViewController(), animated: true)
        }
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
