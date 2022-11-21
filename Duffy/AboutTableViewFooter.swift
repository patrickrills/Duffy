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
    
    private lazy var aboutButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitleColor(Globals.secondaryColor(), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        b.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        return b
    }()
    
    private lazy var debugButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitleColor(Globals.primaryColor(), for: .normal)
        b.setTitle("DEBUG", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        b.addTarget(self, action: #selector(openDebugLog), for: .touchUpInside)
        return b
    }()
    
    private lazy var aboutLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13.0)
        return l
    }()
    
    private weak var navigationController: UINavigationController?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        build()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    private func build() {
        contentView.addSubview(aboutButton)
        contentView.addSubview(debugButton)
        contentView.addSubview(aboutLabel)
        
        NSLayoutConstraint.activate([
            aboutLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            aboutLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            aboutButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            aboutButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            debugButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            debugButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 34.0)
        ])
        
        reset()
    }
    
    private func reset() {
        debugButton.isHidden = true
        aboutButton.setAttributedTitle(nil, for: .normal)
        aboutButton.isHidden = true
        aboutLabel.isHidden = true
        aboutLabel.text = nil
    }
    
    func bind(to category: AboutCategory, parent: UINavigationController?) {
        reset()
        
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
            aboutButton.isHidden = false
            
            debugButton.isHidden = !DebugService.isDebugModeEnabled()
        case .appreciation:
            aboutLabel.isHidden = false
            aboutLabel.text = NSLocalizedString("🙏 Thank you so much for tipping!", comment: "")
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
