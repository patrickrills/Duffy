//
//  AboutTableViewFooter.swift
//  Duffy
//
//  Created by Patrick Rills on 9/3/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class AboutTableViewFooter: UITableViewHeaderFooterView {
    
    @IBOutlet private var aboutButton: UIButton!
    @IBOutlet private var debugButton: UIButton!
    
    private weak var navigationController: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        aboutButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        debugButton.addTarget(self, action: #selector(openDebugLog), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        debugButton.isHidden = true
        aboutButton.setAttributedTitle(nil, for: .normal)
        aboutButton.isHidden = true
    }
    
    func bind(to category: AboutCategory, parent: UINavigationController?) {
        navigationController = parent
        
        switch category {
        case .publishers:
            let version = String(format: NSLocalizedString("Version: %@", comment: ""), Globals.appVersion())
            let privacy = NSLocalizedString("Privacy Policy", comment: "")
            let combined = String(format: "%@ · %@", version, privacy)
            let attributed = NSMutableAttributedString(string: combined)
            
            attributed.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSRange(location: 0, length: combined.count - privacy.count - 1))
            attributed.addAttribute(.foregroundColor, value: Globals.secondaryColor(), range: NSRange(location: combined.count - privacy.count, length: privacy.count))
            aboutButton.setTitleColor(.lightGray, for: .normal)
            aboutButton.setAttributedTitle(attributed, for: .normal)
            
            debugButton.isHidden = !DebugService.isDebugModeEnabled()
        default:
            fatalError("Attempted to bind unsupported category for AboutTableViewFooter")
        }
    }
    
    @objc private func openPrivacyPolicy() {
        navigationController?.openURL("http://www.bigbluefly.com/duffy/privacy")
    }
    
    @objc private func openDebugLog() {
        navigationController?.pushViewController(DebugLogTableViewController(), animated: true)
    }
}
