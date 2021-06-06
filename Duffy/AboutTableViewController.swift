//
//  AboutTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/5/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

enum AboutCategory: Int, CaseIterable {
    case help, feedback, appreciation, publishers
    
    func localizedTitle() -> String {
        switch self {
        case .help:
            return NSLocalizedString("Help", comment: "")
        case .feedback:
            return NSLocalizedString("Feedback", comment: "")
        case .appreciation:
            return NSLocalizedString("Appreciation", comment: "")
        case .publishers:
            return NSLocalizedString("Published By", comment: "")
        }
    }
    
    func options() -> [AboutOption] {
        return AboutOption.allCases.filter { $0.category() == self }
    }
    
    static func option(for indexPath: IndexPath) -> AboutOption {
        guard let category = AboutCategory(rawValue: indexPath.section),
              case let options = category.options(),
              options.count > indexPath.row
        else {
            fatalError("Invalid index path: \(indexPath)")
        }
        
        return category.options()[indexPath.row]
    }
}

enum AboutOption: CaseIterable {
    case goalHowTo, trophies, rate, askAQuestion, bigbluefly, isral, tipJar
    
    func category() -> AboutCategory {
        switch self {
        case .goalHowTo, .trophies:
            return .help
        case .rate, .askAQuestion:
            return .feedback
        case .tipJar:
            return .appreciation
        case .bigbluefly, .isral:
            return .publishers
        }
    }
    
    func localizedTitle() -> String {
        switch self {
        case .goalHowTo:
            return NSLocalizedString("How To Change Your Goal", comment: "")
        case .trophies:
            return NSLocalizedString("Trophies", comment: "")
        case .rate:
            return NSLocalizedString("Rate Duffy", comment: "")
        case .askAQuestion:
            return NSLocalizedString("Ask a Question", comment: "")
        case .tipJar:
            return NSLocalizedString("Tip Jar", comment: "")
        case .bigbluefly:
            return "Big Blue Fly (code)"
        case .isral:
            return "isral Duke (design)"
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .goalHowTo:
            return UIImage(named: "QuestionMark")
        case .trophies:
            return UIImage(named: "Trophy")
        case .rate:
            return UIImage(named: "Star")
        case .askAQuestion:
            return UIImage(named: "Chat")
        case .bigbluefly:
            return UIImage(named: "BigBlueFly")
        case .isral:
            return UIImage(named: "isral")
        case .tipJar:
            //TODO: pull actual icon for dollar and yen
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "dollarsign.circle")
            } else {
                return nil
            }
        }
    }
    
    func select(_ parent: UINavigationController?) {
        switch self {
        case .goalHowTo:
            parent?.pushViewController(GoalInstructionsTableViewController(), animated: true)
        case .trophies:
            parent?.pushViewController(TrophiesViewController(), animated: true)
        case .askAQuestion:
            parent?.openURL("http://www.bigbluefly.com/duffy?contact=1")
        case .rate:
            AppRater.redirectToAppStore()
        case .bigbluefly:
            parent?.openURL("http://www.bigbluefly.com/duffy")
        case .isral:
            parent?.openURL("http://www.isralduke.com")
        case .tipJar:
            parent?.pushViewController(TipViewController(), animated: true)
        }
    }
}

class AboutTableViewController: UITableViewController {

    private enum Constants {
        static let ESTIMATED_ROW_HEIGHT: CGFloat = 44.0
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
        
        tableView.register(BoldActionSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: String(describing: BoldActionSectionHeaderView.self))
        tableView.register(UINib(nibName: String(describing: AboutTableViewFooter.self), bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: String(describing: AboutTableViewFooter.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CELL_ID)
        tableView.estimatedRowHeight = Constants.ESTIMATED_ROW_HEIGHT
    }
    
    @objc private func openPrivacyPolicy() {
        navigationController?.openURL("http://www.bigbluefly.com/duffy/privacy")
    }
    
    @objc private func openDebugLog() {
        navigationController?.pushViewController(DebugLogTableViewController(), animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AboutCategory.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = AboutCategory.allCases[section]
        return AboutOption.allCases.filter { $0.category() == category }.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = AboutCategory.option(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_ID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if #available(iOS 14.0, *) {
            var contentConfig = UIListContentConfiguration.cell()
            contentConfig.text = option.localizedTitle()
            contentConfig.image = option.icon()
            cell.contentConfiguration = contentConfig
        } else {
            cell.textLabel?.text = option.localizedTitle()
            cell.imageView?.image = option.icon()
        }
        
        return cell
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView else { return nil }
        
        let category = AboutCategory.allCases[section]
        header.set(headerText: category.localizedTitle(), actionText: nil, action: nil)
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == self.numberOfSections(in: tableView) - 1,
              let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AboutTableViewFooter.self)) as? AboutTableViewFooter
        else {
            return nil
        }
        
        footer.aboutButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        footer.debugButton.addTarget(self, action: #selector(openDebugLog), for: .touchUpInside)
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = AboutCategory.option(for: indexPath)
        option.select(navigationController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
