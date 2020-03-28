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
    private let PROGRESS_WIDTH: CGFloat = 4.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard progress > 0.0,
            let ringColor = UIColor(named: "RingColor"),
            let successColor = UIColor(named: "SuccessColor") else {
                return
        }
        
        let insetRect = rect.inset(by: UIEdgeInsets(top: PROGRESS_WIDTH, left: PROGRESS_WIDTH, bottom: PROGRESS_WIDTH, right: PROGRESS_WIDTH))
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        let radius = insetRect.size.width / 2.0
        
        if progress < 1.0 {
            let emptyRing = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            emptyRing.lineWidth = 1.0
            if #available(iOS 13.0, *) {
                UIColor.quaternaryLabel.withAlphaComponent(0.1).setStroke()
            } else {
                UIColor.lightGray.withAlphaComponent(0.25).setStroke()
            }
            emptyRing.stroke()
            UIColor.clear.setFill()
            emptyRing.fill()
        }
        
        let startAngle: CGFloat = (START_ANGLE / 360.0 + START_ANGLE) * .pi / 180
        let endAngle: CGFloat = ((progress * 360.0) + START_ANGLE)  * .pi / 180
        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        ring.lineWidth = PROGRESS_WIDTH
        if progress >= 1.0 {
            successColor.withAlphaComponent(0.85).setStroke()
        } else {
            ringColor.withAlphaComponent(0.85).setStroke()
        }
        ring.stroke()
        UIColor.clear.setFill()
        ring.fill()
    }
}
