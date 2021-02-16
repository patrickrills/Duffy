//
//  AboutTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/5/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import SafariServices
import DuffyFramework

class AboutTableViewController: UITableViewController {

    private enum Constants {
        static let ESTIMATED_ROW_HEIGHT : CGFloat = 44.0
        static let CELL_ID = "AboutCell"
    }
    
    init() {
        super.init(style: Globals.tableViewStyle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: Globals.tableViewStyle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("About Duffy", comment: "")
        
        tableView.register(HistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: HistorySectionHeaderView.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CELL_ID)
        tableView.estimatedRowHeight = Constants.ESTIMATED_ROW_HEIGHT
    }
    
    private func openURL(_ urlAsString: String) {
        guard let url = URL(string: urlAsString) else { return }
        
        navigationController?.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    
    @objc private func openPrivacyPolicy() {
        openURL("http://www.bigbluefly.com/duffy/privacy")
    }
    
    @objc private func openDebugLog() {
        navigationController?.pushViewController(DebugLogTableViewController(), animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 3
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text: String
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            text = NSLocalizedString("How To Change Your Goal", comment: "")
        case (0, 1):
            text = NSLocalizedString("Trophies", comment: "")
        case (0, 2):
            text = NSLocalizedString("Ask a Question", comment: "")
        case (1, 0):
            text = NSLocalizedString("Rate Duffy", comment: "")
        default:
            text = "Big Blue Fly"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_ID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var contentConfig = UIListContentConfiguration.cell()
            contentConfig.text = text
            cell.contentConfiguration = contentConfig
        } else {
            cell.textLabel?.text = text
        }
        
        return cell
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HistorySectionHeaderView.self)) as? HistorySectionHeaderView else { return nil }
        
        let sectionTitle: String
        
        switch section {
        case 0:
            sectionTitle = NSLocalizedString("Help", comment: "")
        case 1:
            sectionTitle = NSLocalizedString("Feedback", comment: "")
        case 2:
            sectionTitle = NSLocalizedString("Published By", comment: "")
        default:
            return nil
        }
        
        header.set(headerText: sectionTitle, actionText: nil, action: nil)
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == self.numberOfSections(in: tableView) - 1 else { return nil }
        
        return AboutTableViewFooter.createView(self, action: #selector(openPrivacyPolicy), debugAction: #selector(openDebugLog))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            navigationController?.pushViewController(GoalChangeHowToViewController(), animated: true)
        case (0, 1):
            navigationController?.pushViewController(TrophiesViewController(), animated: true)
        case (0, 2):
            openURL("http://www.bigbluefly.com/duffy?contact=1")
        case (1, 0):
            AppRater.redirectToAppStore()
        default:
            openURL("http://www.bigbluefly.com/duffy")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
