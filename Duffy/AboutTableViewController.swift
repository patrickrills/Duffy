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
    case help, appreciation, publishers
    
    func localizedTitle() -> String {
        switch self {
        case .help:
            return NSLocalizedString("Help", comment: "")
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
    
    var hasFooter: Bool {
        switch self {
        case .appreciation:
            return TipService.getInstance().archive().count > 0
        case .publishers:
            return true
        default:
            return false
        }
    }
}

enum AboutOption: CaseIterable {
    case enableStepCounting, goalHowTo, addStepsToWatchFace, changeMilesOrKilometers, trophies, rate, askAQuestion, bigbluefly, isral, tipJar
    
    func category() -> AboutCategory {
        switch self {
        case .enableStepCounting, .goalHowTo, .addStepsToWatchFace, .changeMilesOrKilometers, .trophies, .askAQuestion:
            return .help
        case .rate, .tipJar:
            return .appreciation
        case .bigbluefly, .isral:
            return .publishers
        }
    }
    
    func localizedTitle() -> String {
        switch self {
        case .goalHowTo:
            return NSLocalizedString("Change my Daily Goal", comment: "")
        case .enableStepCounting:
            return NSLocalizedString("Enable Duffy to Count Steps", comment: "")
        case .addStepsToWatchFace:
            return NSLocalizedString("Add Steps to my Watch Face", comment: "")
        case .changeMilesOrKilometers:
            return NSLocalizedString("Change Miles or Kilometers", comment: "")
        case .trophies:
            return NSLocalizedString("See the Trophies", comment: "")
        case .rate:
            return NSLocalizedString("Rate Duffy", comment: "")
        case .askAQuestion:
            return NSLocalizedString("Ask a Question", comment: "")
        case .tipJar:
            return NSLocalizedString("Tip Jar", comment: "")
        case .bigbluefly:
            return String(format: "Big Blue Fly (%@)", NSLocalizedString("Code", comment: "").lowercased())
        case .isral:
            return String(format: "isral Duke (%@)", NSLocalizedString("Design", comment: "").lowercased())
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .goalHowTo:
            return UIImage(systemName: "shoeprints.fill")
        case .enableStepCounting:
            return UIImage(systemName: "0.square.fill")
        case .addStepsToWatchFace:
            return UIImage(systemName: "applewatch.watchface")
        case .changeMilesOrKilometers:
            return UIImage(systemName: "ruler.fill")
        case .trophies:
            return UIImage(systemName: "trophy.fill")
        case .rate:
            return UIImage(systemName: "star.fill")
        case .askAQuestion:
            return UIImage(systemName: "questionmark.bubble.fill")
        case .bigbluefly:
            return UIImage(named: "BigBlueFly")
        case .isral:
            return UIImage(named: "isral")
        case .tipJar:
            var symbolName = "dollarsign"
            if let lang = NSLocale.current.languageCode, lang.lowercased() == "ja" {
                symbolName = "yensign"
            }
            return UIImage(systemName: symbolName)
        }
    }
    
    func select(_ parent: UINavigationController?) {
        switch self {
        case .goalHowTo:
            parent?.pushViewController(GoalInstructionsTableViewController(), animated: true)
        case .enableStepCounting:
            parent?.openURL("http://www.bigbluefly.com/duffy/stepsnotcounting", appendLanaguageParameter: true)
        case .addStepsToWatchFace:
            parent?.openURL("http://www.bigbluefly.com/duffy/addstepstowatchface", appendLanaguageParameter: true)
        case .changeMilesOrKilometers:
            parent?.openURL("http://www.bigbluefly.com/duffy/changemilesorkilometers", appendLanaguageParameter: true)
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
        static let ICON_CONFIG = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .medium)
        static let ICON_RESERVED_SIZE = CGSize(width: 24.0, height: 24.0)
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
        tableView.register(AboutTableViewFooter.self, forHeaderFooterViewReuseIdentifier: String(describing: AboutTableViewFooter.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CELL_ID)
        tableView.estimatedRowHeight = Constants.ESTIMATED_ROW_HEIGHT
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
        
        var contentConfig = UIListContentConfiguration.cell()
        contentConfig.text = option.localizedTitle()
        contentConfig.image = option.icon()
        contentConfig.imageProperties.reservedLayoutSize = Constants.ICON_RESERVED_SIZE
        contentConfig.imageProperties.preferredSymbolConfiguration = Constants.ICON_CONFIG
        contentConfig.imageProperties.tintColor = Globals.iconColor()
        cell.contentConfiguration = contentConfig
                
        return cell
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: BoldActionSectionHeaderView.self)) as? BoldActionSectionHeaderView else { return nil }
        
        let category = AboutCategory.allCases[section]
        header.set(headerText: category.localizedTitle(), actionText: nil, action: nil)
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard case let category = AboutCategory.allCases[section],
              category.hasFooter,
              let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AboutTableViewFooter.self)) as? AboutTableViewFooter
        else {
            return nil
        }
        
        footer.bind(to: category, parent: navigationController)
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = AboutCategory.option(for: indexPath)
        option.select(navigationController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
