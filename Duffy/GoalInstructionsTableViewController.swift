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
        
        //TODO: Create header
        
        //TODO: Create footer
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return GoalInstructions.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let step = GoalInstructions.allCases[indexPath.section]
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = step.text(useLegacyInstructions: useLegacyInstructions)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
