//
//  MainSectionHeaderView.swift
//  Duffy
//
//  Created by Patrick Rills on 7/14/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class BoldActionSectionHeaderView: UITableViewHeaderFooterView {
    private var button = UIButton(type: .custom)
    private var headerLabel = UILabel(frame: CGRect.zero)
    private var action: (() -> ())?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        buildView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildView()
    }
    
    private func buildView() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        if #available(iOS 13.0, *) {
            headerLabel.textColor = .label
        } else {
            headerLabel.textColor = .black
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        button.setTitleColor(Globals.secondaryColor(), for: .normal)
        button.setTitleColor(Globals.secondaryColor().withAlphaComponent(0.5), for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(onTouchUpInside), for: .touchUpInside)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 2.0)
        ])
    }
    
    @objc private func onTouchUpInside() {
        action?()
    }
    
    func set(headerText: String, actionText: String?, action: (() -> ())?) {
        self.headerLabel.text = headerText
        
        if let actionText = actionText,
            let action = action
        {
            self.button.setTitle(actionText, for: .normal)
            self.action = action
        }
        else
        {
            self.button.isHidden = true
            self.action = nil
        }
    }
}
