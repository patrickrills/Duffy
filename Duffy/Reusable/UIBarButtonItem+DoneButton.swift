//
//  UIBarButtonItem+DoneButton.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/23.
//  Copyright © 2023 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    static func saveBarButtonItem(with systemImageName: String, target: Any, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem.barButtonItem(with: systemImageName, prominent: true, target: target, action: action)
    }
    
    static func closeBarButtonItem(with target: Any, action: Selector) -> UIBarButtonItem {
        if #available(iOS 26.0, *) {
            return UIBarButtonItem(barButtonSystemItem: .close, target: target, action: action)
        } else {
            return UIBarButtonItem.barButtonItem(with: "xmark.circle.fill", prominent: false, target: target, action: action)
        }
    }
    
    static func barButtonItem(with systemImageName: String, prominent: Bool, target: Any, action: Selector) -> UIBarButtonItem {
        
        if #available(iOS 26.0, *) {
            let barButton = UIBarButtonItem(image: UIImage(systemName: systemImageName, withConfiguration: prominent ? UIImage.SymbolConfiguration(paletteColors: [.systemBackground]) : nil), style: prominent ? .prominent : .plain, target: target, action: action)
            
            if prominent {
                barButton.tintColor = Globals.secondaryColor()
            }
            
            return barButton
        } else {
            let palette = UIImage.SymbolConfiguration(paletteColors: [Globals.secondaryColor(), .tertiarySystemFill]).applying(UIImage.SymbolConfiguration(pointSize: 24))
            let xImage = UIImage(systemName: systemImageName, withConfiguration: palette)
            let button = UIButton(type: .system)
            button.setImage(xImage, for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        }
    }
}
