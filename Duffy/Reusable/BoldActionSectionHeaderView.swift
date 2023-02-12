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
        headerLabel.textColor = .label
        
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
        return BoldActionSectionHeaderViewLayoutOptions(labelHeight: 26.0, useHorizontalLayoutMargins: false, horizontalInset: 2.0, topInset: 8.0, actionCenterOffset: 6.0)
    }
    
    @objc private func onTouchUpInside() {
        action?()
    }
    
    func set(headerText: String, actionText: String?, action: (() -> ())?) {
        var att: NSAttributedString?
        if let actionText = actionText {
            att = NSAttributedString(string: actionText)
        }
        set(headerText: headerText, actionAttributedText: att, action: action)
    }
    
    func set(headerText: String, actionAttributedText: NSAttributedString?, action: (() -> ())?) {
        self.headerLabel.text = headerText
        
        if let actionAttributedText = actionAttributedText,
            let action = action
        {
            let mutable = NSMutableAttributedString(attributedString: actionAttributedText)
            mutable.addAttribute(.foregroundColor, value: Globals.secondaryColor(), range: NSRange(location: 0, length: mutable.length))
            
            self.button.isHidden = false
            self.button.setAttributedTitle(mutable, for: .normal)
            self.action = action
        }
        else
        {
            self.button.isHidden = true
            self.action = nil
        }
    }
    
    func addMenu(_ menu: UIMenu) {
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    private func clearMenu() {
        button.menu = nil
        button.showsMenuAsPrimaryAction = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearMenu()
    }
}
