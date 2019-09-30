//
//  AboutTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/5/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {

    let CELL_ID = "AboutCell"
    
    init()
    {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(style: .grouped)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = NSLocalizedString("About Duffy", comment: "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.estimatedRowHeight = 44.0
    }
    
    func openURL(_ urlAsString: String)
    {
        let url = URL(string: urlAsString)
        
        if let u = url
        {
            let safari = SFSafariViewController(url: u)
            self.navigationController?.present(safari, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch (section)
        {
            case 0:
                return 2;
            
            default:
                return 1;
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.section
        {
            case 0:
                switch (indexPath.row)
                {
                    case 0:
                        cell.textLabel?.text = NSLocalizedString("How To Change Your Goal", comment: "")
                        break
                    default:
                        cell.textLabel?.text = NSLocalizedString("Ask a Question", comment: "")
                        break
                }
                break
            case 1:
                cell.textLabel?.text = NSLocalizedString("Rate Duffy", comment: "")
                break
            default:
                cell.textLabel?.text = "Big Blue Fly"
                break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch (section)
        {
            case 0:
                return NSLocalizedString("Help", comment: "")
            
            case 1:
                return NSLocalizedString("Feedback", comment: "")

            case 2:
                return NSLocalizedString("Published By", comment: "")
            
            default:
                return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            if (section == self.numberOfSections(in: tableView) - 1) {
                return AboutTableViewFooter.createView(self, action: #selector(openPrivacyPolicy))
            }

            return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section
        {
            case 0:
                switch (indexPath.row)
                {
                    case 0:
                        self.navigationController?.pushViewController(GoalChangeHowToViewController(), animated: true)
                        break
                    default:
                        openURL("http://www.bigbluefly.com/duffy?contact=1")
                        break
                }
                break
            case 1:
                AppRater.redirectToAppStore()
                break
            default:
                openURL("http://www.bigbluefly.com")
                break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func openPrivacyPolicy() {
        openURL("http://www.bigbluefly.com/duffy/privacy")
    }
}
