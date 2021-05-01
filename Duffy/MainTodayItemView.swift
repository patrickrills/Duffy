//
//  MainTodayItemView.swift
//  Duffy
//
//  Created by Patrick Rills on 3/20/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class MainTodayItemView: UIView {

    //MARK: - Binding
    
    @IBOutlet private weak var itemIcon: UIImageView!
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    private lazy var defaultTextColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkText
        }
    }()
    
    func bind(title: String, value: String, image: UIImage) {
        bind(title: title, value: value, valueColor: defaultTextColor, image: image, symbol: nil, imageTintColor: Globals.lightGrayColor())
    }
    
    func bind(title: String, value: String, valueColor: UIColor, image: UIImage?, symbol: String?, imageTintColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = valueColor
        
        if let symbol = symbol,
           symbol.count > 0 {
            symbolLabel.isHidden = false
            symbolLabel.text = symbol
            itemIcon.isHidden = true
        } else {
            itemIcon.isHidden = false
            itemIcon.image = image
            itemIcon.tintColor = imageTintColor
            symbolLabel.isHidden = true
            symbolLabel.text = nil
        }
    }
    
    //MARK: - Construction
    
    // Required to use a xib in a xib
    // Reference: https://github.com/BareFeetWare/BFWControls/blob/develop/BFWControls/Modules/NibReplaceable/View/UIView%2BCopy.swift
    
    override func awakeAfter(using coder: NSCoder) -> Any? {
        guard subviews.isEmpty else {
            return super.awakeAfter(using: coder)
        }

        return createViewFromNib()
    }
    
    func createViewFromNib() -> MainTodayItemView {
        guard let nibViews = Bundle.main.loadNibNamed("MainTodayItemView", owner: nil, options: nil),
              let nibView = nibViews.first as? MainTodayItemView
        else {
            fatalError("Could not find an instance of class MainTodayItemView in xib")
        }
        
        nibView.backgroundColor = .clear
        nibView.copyConstraints(from: self)
        
        return nibView
    }
    
    func copyConstraints(from view: UIView) {
            translatesAutoresizingMaskIntoConstraints = view.translatesAutoresizingMaskIntoConstraints
            for constraint in view.constraints {
                if var firstItem = constraint.firstItem as? UIView {
                    var secondItem = constraint.secondItem as? UIView
                    if firstItem == view {
                        firstItem = self
                    }
                    if secondItem == view {
                        secondItem = self
                    }
                    let copiedConstraint = NSLayoutConstraint(
                        item: firstItem,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: secondItem,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    )
                    addConstraint(copiedConstraint)
                } else {
                    debugPrint("copyConstraintsFromView: error: firstItem is not a UIView")
                }
                for axis in [NSLayoutConstraint.Axis.horizontal, NSLayoutConstraint.Axis.vertical] {
                    setContentCompressionResistancePriority(view.contentCompressionResistancePriority(for: axis), for: axis)
                    setContentHuggingPriority(view.contentHuggingPriority(for: axis), for: axis)
                }
            }
        }

}
