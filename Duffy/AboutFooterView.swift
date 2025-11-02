//
//  AboutFooterView.swift
//  Duffy
//
//  Created by Patrick Rills on 2/19/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class AboutFooterView: UIView {

    init() {
        super.init(frame: .zero)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        let horizontalStack = UIStackView(frame: .zero)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 10.0
        addSubview(horizontalStack)
        
        let aboutButton = UIButton(type: .custom)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        aboutButton.layer.cornerRadius = 8.0
        aboutButton.setAttributedTitle(attributedButtonLabel(text: NSLocalizedString("About Duffy", comment: ""), imageSystemName: "info.circle.fill", color: Globals.secondaryColor()), for: .normal)
        aboutButton.addTarget(self, action: #selector(openAbout), for: .touchUpInside)
        aboutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        aboutButton.titleLabel?.minimumScaleFactor = 0.75
        horizontalStack.addArrangedSubview(aboutButton)
        
        let tipSymbolName = TipCurrencySymbolPrefix.prefix(for: Locale.current).rawValue + ".circle.fill"
        let tipButton = UIButton(type: .custom)
        tipButton.translatesAutoresizingMaskIntoConstraints = false
        tipButton.layer.cornerRadius = 8.0
        tipButton.setAttributedTitle(attributedButtonLabel(text: NSLocalizedString("Tip Jar", comment: ""), imageSystemName: tipSymbolName, color: .systemGreen), for: .normal)
        tipButton.addTarget(self, action: #selector(openTipJar), for: .touchUpInside)
        tipButton.titleLabel?.adjustsFontSizeToFitWidth = true
        tipButton.titleLabel?.minimumScaleFactor = 0.75
        horizontalStack.addArrangedSubview(tipButton)
        
        aboutButton.layer.cornerCurve = .continuous
        tipButton.layer.cornerCurve = .continuous
        aboutButton.backgroundColor = .tertiarySystemBackground
        tipButton.backgroundColor = .tertiarySystemBackground
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 32.0),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18.0)
        ])
    }

    private func attributedButtonLabel(text: String, imageSystemName: String, color: UIColor) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        let symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .body))
        let symbolImage = UIImage(systemName: imageSystemName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        let symbolTextAttachment = NSTextAttachment()
        symbolTextAttachment.image = symbolImage
        let attachmentString = NSMutableAttributedString(attachment: symbolTextAttachment)
        attributedText.append(attachmentString)
        attributedText.append(NSAttributedString(string: " "))
        attributedText.append(NSAttributedString(string: text))
        attributedText.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, attributedText.length))

        return attributedText
    }
    
    @objc private func openAbout() {
        open(viewController: AboutTableViewController())
    }
    
    @objc private func openTipJar() {
        open(viewController: TipViewController())
    }
    
    private func open(viewController: UIViewController) {
        guard let presenter = nearestViewController ?? window?.rootViewController else {
            return
        }
        
        let topMost = topMostViewController(from: presenter) ?? presenter
        topMost.present(ModalNavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
    
    private var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
    
    private func topMostViewController(from base: UIViewController?) -> UIViewController? {
        guard let base = base else { return nil }
        if let nav = base as? UINavigationController {
            return topMostViewController(from: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(from: tab.selectedViewController)
        }
        if let presented = base.presentedViewController {
            return topMostViewController(from: presented)
        }
        return base
    }
}
