//
//  ProgressRingView.swift
//  DuffyToday
//
//  Created by Patrick Rills on 3/17/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import UIKit

class ProgressRingView: UIView {

    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    private let START_ANGLE: CGFloat = 270.0
    private let INSET: CGFloat = 4.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard progress > 0.0,
            let ringColor = UIColor(named: "RingColor"),
            let successColor = UIColor(named: "SuccessColor") else {
                return
        }
        
        let insetRect = rect.inset(by: UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET))
        let startAngle: CGFloat = (START_ANGLE / 360.0 + START_ANGLE) * .pi / 180
        let endAngle: CGFloat = ((progress * 360.0) + START_ANGLE)  * .pi / 180
        let ring = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0), radius: insetRect.size.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ring.lineWidth = 4.0
        if progress >= 1.0 {
            successColor.setStroke()
        } else {
            ringColor.setStroke()
        }
        ring.stroke()
        UIColor.clear.setFill()
        ring.fill()
    }
}
