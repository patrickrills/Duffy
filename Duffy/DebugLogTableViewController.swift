//
//  DebugLogTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 12/24/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class DebugLogTableViewController: UITableViewController {

    var log = LoggingService.getFullDebugLog()
    let dateFormatter = DateFormatter()
    private var shareSheet: UIDocumentInteractionController?
    
    init() {
        super.init(style: .grouped)
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        title = "Debug"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(showShareSheet)),
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearLog))
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 2, 3:
            return 1
        default:
            return log.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content: UIListContentConfiguration = (indexPath.section == 0 ? UIListContentConfiguration.valueCell() : UIListContentConfiguration.subtitleCell())

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                content.text = "Transfers remaining"
                content.secondaryText = "\(WCSessionService.getInstance().transfersRemaining())"
                break
            case 1:
                content.text = "Goal reached count"
                content.secondaryText = "\(HealthCache.getGoalReachedCount())"
                break
            case 2:
                content.text = "Asked for rating"
                content.secondaryText = AppRater.haveAsked() ? "1" : "0"
                break
            case 3:
                content.text = "Cached steps"
                content.secondaryText = "\(HealthCache.lastSteps(for: Date()))"
            default:
                break
            }
        case 2:
            content.text = "Export to CSV"
            content.textProperties.color = .systemBlue
            break
        case 3:
            content.text = "Clear Log"
            content.textProperties.color = .systemRed
            break
        default:
            let logEntry = log[indexPath.row]
            content.text = dateFormatter.string(from: logEntry.timestamp)
            content.secondaryText = logEntry.message
            content.secondaryTextProperties.numberOfLines = 0
            content.secondaryTextProperties.color = logEntry.textColor()
            break
        }
        
        cell.contentConfiguration = content
        cell.selectionStyle = indexPath.section == 2 ? .default : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Data"
        case 1:
            return "Log"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 2:
                tableView.deselectRow(at: indexPath, animated: true)
                showShareSheet()
                return
            case 3:
                clearLog()
                return
            default:
                return
        }
    }
    
    @objc private func showShareSheet() {
        guard let csvURL = DebugService.exportLogToCSV() else {
            return
        }
        
        let docController = UIDocumentInteractionController(url: csvURL)
        docController.name = "log.csv"
        shareSheet = docController
        docController.presentOptionsMenu(from: self.view.frame, in: self.view, animated: true)
    }
    
    @objc private func clearLog() {
        let confirm = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        confirm.addAction(UIAlertAction(title: "Clear Log", style: .destructive, handler: {
            [weak self] action in
            LoggingService.clearLog()
            self?.log = LoggingService.getFullDebugLog()
            self?.tableView.reloadData()
        }))
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(confirm, animated: true, completion: nil)
    }
}
