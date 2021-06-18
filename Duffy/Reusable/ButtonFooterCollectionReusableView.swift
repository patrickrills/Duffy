//
//  ButtonFooterCollectionReusableView.swift
//  Duffy
//
//  Created by Patrick Rills on 5/22/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

class ButtonFooterCollectionReusableView: UICollectionReusableView {
    
    private lazy var buttonFooterView: ButtonFooterView = {
        let footer = ButtonFooterView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.buttonAttributedText = NSAttributedString(string: "")
        footer.addTarget(self, action: #selector(pressed))
        footer.separatorIsVisible = false
        footer.backgroundColor = .clear
        return footer
    }()
    
    private var pressHandler: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private let FOOTER_BUTTON_HEIGHT: CGFloat = 48.0
    
    private func createView() {
        backgroundColor = .clear
        addSubview(buttonFooterView)
        NSLayoutConstraint.activate([
            buttonFooterView.topAnchor.constraint(equalTo: topAnchor),
            buttonFooterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonFooterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonFooterView.heightAnchor.constraint(equalToConstant: FOOTER_BUTTON_HEIGHT)
        ])
    }
    
    @objc private func pressed() {
        pressHandler?()
    }
    
    func bind(_ buttonText: String, onPress: @escaping () -> ()) {
        buttonFooterView.buttonAttributedText = NSAttributedString(string: buttonText)
        pressHandler = onPress
    }
}
