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

    var log = LoggingService.getDebugLog()
    let dateFormatter = DateFormatter()
    
    init() {
        super.init(style: .grouped)
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        title = "Debug"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 2:
            return 1
        default:
            return log.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: (indexPath.section == 0 ? .value1 : .subtitle), reuseIdentifier: nil)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Transfers remaining"
                cell.detailTextLabel?.text = "\(WCSessionService.getInstance().transfersRemaining())"
                break
            case 1:
                cell.textLabel?.text = "Goal reached count"
                cell.detailTextLabel?.text = "\(HealthCache.getGoalReachedCount())"
                break
            case 2:
                cell.textLabel?.text = "Asked for rating"
                cell.detailTextLabel?.text = AppRater.haveAsked() ? "1" : "0"
                break
            default:
                break
            }
        case 2:
            cell.textLabel?.text = "Clear Log"
            cell.textLabel?.textColor = .red
            break
        default:
            let logEntry = log[indexPath.row]
            cell.textLabel?.text = dateFormatter.string(from: logEntry.timestamp)
            cell.detailTextLabel?.text = logEntry.message
            cell.detailTextLabel?.numberOfLines = 0
            break
        }
        
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
        if indexPath.section == 2 {
            LoggingService.clearLog()
            log = LoggingService.getDebugLog()
            tableView.reloadData()
        }
    }
}
