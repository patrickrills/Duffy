//
//  MainTableViewHeader.swift
//  Duffy
//
//  Created by Patrick Rills on 4/4/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class MainTableViewHeader: UIView {

    private lazy var logo: UIImageView = {
        let img = UIImageView(image: UIImage(named: "DuffyLogo02")?.withRenderingMode(.alwaysTemplate))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = Globals.primaryColor()
        return img
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .gray
        }
        let spin = UIActivityIndicatorView(style: style)
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.isHidden = true
        spin.stopAnimating()
        return spin
    }()
    
    var isLoading: Bool = true {
        didSet {
            if isLoading {
                spinner.isHidden = false
                spinner.startAnimating()
                logo.isHidden = true
            } else {
                spinner.isHidden = true
                spinner.stopAnimating()
                logo.isHidden = false
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        buildView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }
    
    private func buildView() {
        backgroundColor = .clear
        addSubview(logo)
        addSubview(spinner)
        
        NSLayoutConstraint.activate([
            logo.heightAnchor.constraint(equalToConstant: 64.0),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
            logo.centerYAnchor.constraint(equalTo: centerYAnchor),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
