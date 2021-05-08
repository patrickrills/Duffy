//
//  ThinSeparator.swift
//  Duffy
//
//  Created by Patrick Rills on 3/21/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class ThinSeparator: UIView {

    private let separatorHeight: CGFloat = 1.0 / UIScreen.main.scale
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let separator = UIBezierPath(rect: CGRect(x: 0, y: (rect.height / 2.0) - separatorHeight, width: rect.width, height: separatorHeight))
        Globals.separatorColor().setFill()
        separator.fill()
    }

}
