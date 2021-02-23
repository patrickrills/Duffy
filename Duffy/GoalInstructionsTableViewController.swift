//
//  GoalInstructionsTableViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 2/16/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class GoalInstructionsTableViewController: UITableViewController {

    private var useLegacyInstructions: Bool {
        let cachedWatchVersion = Globals.watchSystemVersion()
        return cachedWatchVersion > 0.0 && cachedWatchVersion < 6.0
    }
    
    init() {
        super.init(style: Globals.tableViewStyle())
    }
    
    required init?(coder: NSCoder) {
        super.init(style: Globals.tableViewStyle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = GoalInstructions.title()
        
        tableView.register(UINib(nibName: String(describing: GoalInstructionsTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: GoalInstructionsTableViewCell.self))
        tableView.rowHeight = GoalInstructionsTableViewCell.CELL_HEIGHT
        
        buildHeader()
        buildFooter()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let container = tableView.tableHeaderView,
           let header = container.subviews.first
        {
            let widthWithMargin = tableView.layoutMarginsGuide.layoutFrame.width
            let calculatedSize = header.systemLayoutSizeFitting(CGSize(width: widthWithMargin, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
            let roundedHeight = CGFloat(ceil(Double(calculatedSize.height)))
            container.frame = CGRect(x: 0, y: header.frame.origin.y, width: tableView.frame.size.width, height: roundedHeight)
        }
        
        if let footer = tableView.tableFooterView {
            footer.frame = CGRect(x: 0, y: footer.frame.origin.y, width: self.view.frame.width, height: 44.0)
        }
    }
    
    @IBAction func viewTrophies() {
        navigationController?.pushViewController(TrophiesViewController(), animated: true)
    }
    
    private func buildHeader() {
        let container = UIView()
        container.backgroundColor = .groupTableViewBackground
        
        let header = GoalInstructionsTableViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(header)
        
        tableView.tableHeaderView = container
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: container.topAnchor),
            header.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            header.leadingAnchor.constraint(equalTo: tableView.layoutMarginsGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: tableView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    private func buildFooter() {
        let footer = ButtonFooterView()
        footer.buttonAttributedText = NSAttributedString(string: "See the Trophies")
        footer.addTarget(self, action: #selector(viewTrophies))
        footer.separatorIsVisible = false
        tableView.tableFooterView = footer
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return GoalInstructions.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GoalInstructionsTableViewCell.self), for: indexPath) as! GoalInstructionsTableViewCell
        let step = GoalInstructions.allCases[indexPath.section]
        cell.bind(to: step, useLegacyInstructions: useLegacyInstructions)
        return cell
    }
    
    private let STEP_SPACING: CGFloat = 20.0
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return STEP_SPACING / 2.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return STEP_SPACING / 2.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
