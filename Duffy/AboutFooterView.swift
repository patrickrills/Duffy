//
//  AboutFooterView.swift
//  Duffy
//
//  Created by Patrick Rills on 2/19/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

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
        aboutButton.setAttributedTitle(attributedButtonLabel(text: "About Duffy", imageSystemName: "info.circle.fill", color: Globals.secondaryColor()), for: .normal)
        horizontalStack.addArrangedSubview(aboutButton)
        
        let tipButton = UIButton(type: .custom)
        tipButton.translatesAutoresizingMaskIntoConstraints = false
        tipButton.layer.cornerRadius = 8.0
        tipButton.setAttributedTitle(attributedButtonLabel(text: "Tip Jar", imageSystemName: "dollarsign.circle.fill", color: .systemGreen), for: .normal)
        horizontalStack.addArrangedSubview(tipButton)
        
        aboutButton.backgroundColor = Globals.secondaryColor().withAlphaComponent(0.08)
        tipButton.backgroundColor = .systemGreen.withAlphaComponent(0.08)
        
        if #available(iOS 13.0, *) {
            aboutButton.layer.cornerCurve = CALayerCornerCurve.continuous
            tipButton.layer.cornerCurve = CALayerCornerCurve.continuous
//            aboutButton.backgroundColor = .tertiarySystemBackground
//            tipButton.backgroundColor = .tertiarySystemBackground
        }
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 32.0),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18.0)
        ])
    }

    private func attributedButtonLabel(text: String, imageSystemName: String, color: UIColor) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()

        if #available(iOS 13.0, *) {
            let symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .body))
            let symbolImage = UIImage(systemName: imageSystemName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
            let symbolTextAttachment = NSTextAttachment()
            symbolTextAttachment.image = symbolImage
            let attachmentString = NSMutableAttributedString(attachment: symbolTextAttachment)
            attributedText.append(attachmentString)
            attributedText.append(NSAttributedString(string: " "))
        }

        attributedText.append(NSAttributedString(string: text))
        attributedText.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, attributedText.length))

        return attributedText
    }
}
