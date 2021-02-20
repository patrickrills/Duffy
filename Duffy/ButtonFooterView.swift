//
//  ButtonFooterView.swift
//  Duffy
//
//  Created by Patrick Rills on 11/10/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class ButtonFooterView: UIView {
    
    init() {
        super.init(frame: .zero)
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    var buttonAttributedText: NSAttributedString? {
        didSet {
            footerButton.setAttributedTitle(buttonAttributedText, for: .normal)
        }
    }
    
    var separatorIsVisible: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isButtonHidden: Bool = false {
        didSet {
            footerButton.isHidden = isButtonHidden
        }
    }
    
    func addTarget(_ target: Any?, action: Selector) {
        footerButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    private lazy var footerButton : UIButton = {
        let footerButton = UIButton(type: .custom)
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerButton.setTitleColor(Globals.secondaryColor(), for: .normal)
        footerButton.setTitleColor(Globals.secondaryColor().withAlphaComponent(0.4), for: .highlighted)
        footerButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        footerButton.setAttributedTitle(buttonAttributedText, for: .normal)
        return footerButton
    }()
    
    private func createView() {
        backgroundColor = .clear
        addSubview(footerButton)
        NSLayoutConstraint.activate([
            footerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            footerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            footerButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if separatorIsVisible {
            let separator = UIBezierPath(rect: CGRect(x: 0, y: 1, width: rect.width, height: 0.33))
            Globals.separatorColor().setFill()
            separator.fill()
        }
    }
}
