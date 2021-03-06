//
//  MainSectionHeaderView.swift
//  Duffy
//
//  Created by Patrick Rills on 7/14/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class BoldActionSectionHeaderView: UITableViewHeaderFooterView {
    
    static let estimatedHeight: CGFloat = 50.0
    
    private var button = UIButton(type: .custom)
    private var headerLabel = UILabel(frame: CGRect.zero)
    private var action: (() -> ())?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        buildView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("xib is not used for BoldActionSectionHeaderView")
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
        
        createConstraints()
    }
    
    typealias BoldActionSectionHeaderViewLayoutOptions = (labelHeight: CGFloat, useHorizontalLayoutMargins: Bool, horizontalInset: CGFloat, topInset: CGFloat, actionCenterOffset: CGFloat)
    
    private func createConstraints() {
        let options = layoutOptions()
        let height = headerLabel.heightAnchor.constraint(equalToConstant: options.labelHeight)
        height.priority = UILayoutPriority(rawValue: 999.0)
        
        let superLeadingAnchor = options.useHorizontalLayoutMargins ? contentView.layoutMarginsGuide.leadingAnchor : contentView.leadingAnchor
        let superTrailingAnchor = options.useHorizontalLayoutMargins ? contentView.layoutMarginsGuide.trailingAnchor : contentView.trailingAnchor
        
        NSLayoutConstraint.activate([
            height,
            headerLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: options.topInset),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: superLeadingAnchor, constant: options.horizontalInset),
            button.trailingAnchor.constraint(equalTo: superTrailingAnchor, constant: -options.horizontalInset),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: options.actionCenterOffset)
        ])
    }
    
    func layoutOptions() -> BoldActionSectionHeaderViewLayoutOptions {
        var useLayoutMargins = true
        if #available(iOS 13.0, *) {
            useLayoutMargins = false
        }
        
        return BoldActionSectionHeaderViewLayoutOptions(labelHeight: 26.0, useHorizontalLayoutMargins: useLayoutMargins, horizontalInset: 2.0, topInset: 8.0, actionCenterOffset: 6.0)
    }
    
    @objc private func onTouchUpInside() {
        action?()
    }
    
    func set(headerText: String, actionText: String?, action: (() -> ())?) {
        self.headerLabel.text = headerText
        
        if let actionText = actionText,
            let action = action
        {
            self.button.isHidden = false
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
