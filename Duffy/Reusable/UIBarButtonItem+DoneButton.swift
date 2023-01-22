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
    
    static func doneBarButtonItem(with systemImageName: String, target: Any, action: Selector) -> UIBarButtonItem {
        if #available(iOS 15.0, *) {
            let palette = UIImage.SymbolConfiguration(paletteColors: [Globals.secondaryColor(), .tertiarySystemFill]).applying(UIImage.SymbolConfiguration(pointSize: 24))
            let xImage = UIImage(systemName: systemImageName, withConfiguration: palette)
            let button = UIButton(type: .system)
            button.setImage(xImage, for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        } else {
            return UIBarButtonItem(image: UIImage(systemName: systemImageName), style: .plain, target: target, action: action)
        }
    }
    
}
