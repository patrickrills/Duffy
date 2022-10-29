//
//  TipCollectionViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TipCollectionViewCell: UICollectionViewCell {
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .systemGreen
        label.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.textAlignment = .center
        return label
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView(style: .medium)
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.hidesWhenStopped = true
        spin.isHidden = true
        return spin
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    private func build() {
        let normalBackgroundView = UIView(frame: bounds)
        normalBackgroundView.backgroundColor = .secondarySystemGroupedBackground
        backgroundView = normalBackgroundView

        let highlightedBackgroundView = UIView(frame: bounds)
        highlightedBackgroundView.backgroundColor = Globals.veryLightGrayColor()
        selectedBackgroundView = highlightedBackgroundView
        
        contentView.addSubview(priceLabel)
        contentView.addSubview(spinner)
                
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        layer.cornerRadius = 10.0
        clipsToBounds = true
    }
    
    func bind(to tip: TipOption?) {
        if let tip = tip {
            priceLabel.text = tip.formattedPrice
            spinner.stopAnimating()
        } else {
            priceLabel.text = nil
            spinner.startAnimating()
        }
    }
}
