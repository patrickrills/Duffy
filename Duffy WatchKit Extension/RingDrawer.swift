//
//  RingDrawer.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 11/8/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation
import CoreGraphics
import DuffyWatchFramework

class RingDrawer {
    
    class func drawRing(_ steps: Steps, goal: Steps, width: CGFloat) -> UIImage? {
        Self.drawRing(steps, goal: goal, width: width, includeCenterImage: true)
    }
    
    class func drawRing(_ steps: Steps, goal: Steps, width: CGFloat, includeCenterImage: Bool) -> UIImage? {
        let size = CGSize(width: width, height: width)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)
        
        let lineWidth: CGFloat = 8.0 //TODO: width / 4.0
        let inset: CGFloat = lineWidth / 2.0
        let insetRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
        
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let radius = insetRect.size.width / 2.0
        let start: CGFloat = 270.0
        let progress: CGFloat = CGFloat(steps) / CGFloat(goal)
        
        if progress < 1.0 {
            let emptyRing = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            emptyRing.lineWidth = lineWidth
            UIColor.white.withAlphaComponent(0.3).setStroke()
            emptyRing.stroke()
            UIColor.clear.setFill()
            emptyRing.fill()
        }
        
        let startAngle: CGFloat = start * .pi / 180.0
        let endAngle: CGFloat = ((progress * 360.0) + start)  * .pi / 180.0
        if endAngle > startAngle {
            let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ring.lineWidth = lineWidth
            UIColor.white.setStroke()
            ring.stroke()
            UIColor.clear.setFill()
            ring.fill()
        }
        
        if includeCenterImage, let image = UIImage(named: "XLargeShoe") { //Asset libraries are not available to complication on older watchOS versions (< 5.0)
            let imageSize = insetRect.size.height / 2.0
            image.draw(in: CGRect(x: (size.width / 2.0) - (imageSize / 2.0), y: (size.height / 2.0) - (imageSize / 2.0), width: imageSize, height: imageSize))
        }
        
        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
    
}
