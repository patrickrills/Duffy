//
//  MainTableViewHeader.swift
//  Duffy
//
//  Created by Patrick Rills on 4/4/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class MainTableViewHeader: UIView {

    private enum Constants {
        static let TOP_MARGIN: CGFloat = 16.0
        static let IMAGE_SIZE: CGFloat = 64.0
        static let IMAGE_NAME: String = "DuffyLogo02"
    }
    
    private lazy var logo: UIImageView = {
        let img = UIImageView(image: UIImage(named: Constants.IMAGE_NAME)?.withRenderingMode(.alwaysTemplate))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = Globals.primaryColor()
        return img
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        let spin = UIActivityIndicatorView(style: .large)
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
    
    var suggestedHeight: CGFloat {
        return Constants.TOP_MARGIN + Constants.IMAGE_SIZE
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
            logo.heightAnchor.constraint(equalToConstant: Constants.IMAGE_SIZE),
            logo.widthAnchor.constraint(equalTo: logo.heightAnchor),
            logo.topAnchor.constraint(equalTo: topAnchor, constant: Constants.TOP_MARGIN),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: logo.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
