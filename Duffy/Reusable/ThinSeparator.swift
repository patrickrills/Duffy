//
//  ThinSeparator.swift
//  Duffy
//
//  Created by Patrick Rills on 3/21/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class ThinSeparator: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let separator = UIBezierPath(rect: CGRect(x: 0, y: (rect.height / 2.0) - 0.165, width: rect.width, height: 0.33))
        Globals.separatorColor().setFill()
        separator.fill()
    }

}
