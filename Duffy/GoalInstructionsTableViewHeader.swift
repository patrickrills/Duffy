//
//  GoalInstructionsTableViewHeader.swift
//  Duffy
//
//  Created by Patrick Rills on 2/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class GoalInstructionsTableViewHeader: UIView {

    init() {
        super.init(frame: .zero)
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private lazy var contentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear
        return content
    }()
    
    private lazy var goalCaptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Your Goal".uppercased()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 11.0)
        return lbl
    }()
    
    private lazy var goalValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = Globals.stepsFormatter().string(for: HealthCache.dailyGoal())
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 34.0, weight: .black)
        return lbl
    }()
    
    private lazy var goalDescriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = GoalInstructions.headline()
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 17.0)
        lbl.setContentHuggingPriority(.required, for: .vertical)
        lbl.setContentCompressionResistancePriority(.required, for: .vertical)
        let height = lbl.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.MIN_DESCR_HEIGHT)
        height.isActive = true
        height.priority = .defaultHigh
        return lbl
    }()
    
    private enum Constants {
        static let PADDING: CGFloat = 24.0
        static let MIN_DESCR_HEIGHT: CGFloat = 75.0
        static let DESCR_SPACING: CGFloat = 16.0
    }

    private func createView() {
        addSubview(contentView)
        contentView.addSubview(goalCaptionLabel)
        contentView.addSubview(goalValueLabel)
        contentView.addSubview(goalDescriptionLabel)
        
        let top = contentView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.PADDING)
        let bottom = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.PADDING)
        top.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1.0)
        bottom.priority = top.priority
        
        NSLayoutConstraint.activate([
            top,
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottom,
            goalCaptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            goalCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            goalCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            goalValueLabel.topAnchor.constraint(equalTo: goalCaptionLabel.bottomAnchor),
            goalValueLabel.leadingAnchor.constraint(equalTo: goalCaptionLabel.leadingAnchor),
            goalValueLabel.trailingAnchor.constraint(equalTo: goalCaptionLabel.trailingAnchor),
            goalDescriptionLabel.topAnchor.constraint(equalTo: goalValueLabel.bottomAnchor, constant: Constants.DESCR_SPACING),
            goalDescriptionLabel.leadingAnchor.constraint(equalTo: goalCaptionLabel.leadingAnchor),
            goalDescriptionLabel.trailingAnchor.constraint(equalTo: goalCaptionLabel.trailingAnchor),
            goalDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

}
