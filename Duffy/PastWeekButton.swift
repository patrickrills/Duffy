//
//  PastWeekButton.swift
//  Duffy
//
//  Created by Patrick Rills on 1/22/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import UIKit

class PastWeekButton: UIButton
{

    override func draw(_ rect: CGRect)
    {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.298, green: 0.557, blue: 0.855, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 37.23, y: 8.07))
        bezierPath.addCurve(to: CGPoint(x: 35.41, y: 7.29), controlPoint1: CGPoint(x: 36.72, y: 7.55), controlPoint2: CGPoint(x: 36.11, y: 7.29))
        bezierPath.addLine(to: CGPoint(x: 32.81, y: 7.29))
        bezierPath.addLine(to: CGPoint(x: 32.81, y: 5.3))
        bezierPath.addCurve(to: CGPoint(x: 31.86, y: 2.97), controlPoint1: CGPoint(x: 32.81, y: 4.4), controlPoint2: CGPoint(x: 32.49, y: 3.62))
        bezierPath.addCurve(to: CGPoint(x: 29.57, y: 2), controlPoint1: CGPoint(x: 31.22, y: 2.32), controlPoint2: CGPoint(x: 30.46, y: 2))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 2))
        bezierPath.addCurve(to: CGPoint(x: 25.98, y: 2.97), controlPoint1: CGPoint(x: 27.38, y: 2), controlPoint2: CGPoint(x: 26.62, y: 2.32))
        bezierPath.addCurve(to: CGPoint(x: 25.03, y: 5.3), controlPoint1: CGPoint(x: 25.35, y: 3.62), controlPoint2: CGPoint(x: 25.03, y: 4.4))
        bezierPath.addLine(to: CGPoint(x: 25.03, y: 7.29))
        bezierPath.addLine(to: CGPoint(x: 17.25, y: 7.29))
        bezierPath.addLine(to: CGPoint(x: 17.25, y: 5.3))
        bezierPath.addCurve(to: CGPoint(x: 16.29, y: 2.97), controlPoint1: CGPoint(x: 17.25, y: 4.4), controlPoint2: CGPoint(x: 16.93, y: 3.62))
        bezierPath.addCurve(to: CGPoint(x: 14, y: 2), controlPoint1: CGPoint(x: 15.66, y: 2.32), controlPoint2: CGPoint(x: 14.9, y: 2))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 2))
        bezierPath.addCurve(to: CGPoint(x: 10.42, y: 2.97), controlPoint1: CGPoint(x: 11.82, y: 2), controlPoint2: CGPoint(x: 11.05, y: 2.32))
        bezierPath.addCurve(to: CGPoint(x: 9.46, y: 5.3), controlPoint1: CGPoint(x: 9.78, y: 3.62), controlPoint2: CGPoint(x: 9.46, y: 4.4))
        bezierPath.addLine(to: CGPoint(x: 9.46, y: 7.29))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 7.29))
        bezierPath.addCurve(to: CGPoint(x: 5.05, y: 8.07), controlPoint1: CGPoint(x: 6.17, y: 7.29), controlPoint2: CGPoint(x: 5.56, y: 7.55))
        bezierPath.addCurve(to: CGPoint(x: 4.28, y: 9.93), controlPoint1: CGPoint(x: 4.53, y: 8.59), controlPoint2: CGPoint(x: 4.28, y: 9.21))
        bezierPath.addLine(to: CGPoint(x: 4.28, y: 36.36))
        bezierPath.addCurve(to: CGPoint(x: 5.05, y: 38.22), controlPoint1: CGPoint(x: 4.28, y: 37.07), controlPoint2: CGPoint(x: 4.53, y: 37.69))
        bezierPath.addCurve(to: CGPoint(x: 6.87, y: 39), controlPoint1: CGPoint(x: 5.56, y: 38.74), controlPoint2: CGPoint(x: 6.17, y: 39))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 39))
        bezierPath.addCurve(to: CGPoint(x: 37.23, y: 38.22), controlPoint1: CGPoint(x: 36.11, y: 39), controlPoint2: CGPoint(x: 36.72, y: 38.74))
        bezierPath.addCurve(to: CGPoint(x: 38, y: 36.36), controlPoint1: CGPoint(x: 37.74, y: 37.69), controlPoint2: CGPoint(x: 38, y: 37.07))
        bezierPath.addLine(to: CGPoint(x: 38, y: 9.93))
        bezierPath.addCurve(to: CGPoint(x: 37.23, y: 8.07), controlPoint1: CGPoint(x: 38, y: 9.21), controlPoint2: CGPoint(x: 37.74, y: 8.59))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 36.36))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 29.09))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 6.87, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 21.16))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.25, y: 11.71))
        bezierPath.addCurve(to: CGPoint(x: 12.06, y: 11.25), controlPoint1: CGPoint(x: 12.12, y: 11.58), controlPoint2: CGPoint(x: 12.06, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 12.06, y: 5.3))
        bezierPath.addCurve(to: CGPoint(x: 12.25, y: 4.84), controlPoint1: CGPoint(x: 12.06, y: 5.12), controlPoint2: CGPoint(x: 12.12, y: 4.97))
        bezierPath.addCurve(to: CGPoint(x: 12.71, y: 4.64), controlPoint1: CGPoint(x: 12.38, y: 4.71), controlPoint2: CGPoint(x: 12.53, y: 4.64))
        bezierPath.addLine(to: CGPoint(x: 14, y: 4.64))
        bezierPath.addCurve(to: CGPoint(x: 14.46, y: 4.84), controlPoint1: CGPoint(x: 14.18, y: 4.64), controlPoint2: CGPoint(x: 14.33, y: 4.71))
        bezierPath.addCurve(to: CGPoint(x: 14.65, y: 5.3), controlPoint1: CGPoint(x: 14.59, y: 4.97), controlPoint2: CGPoint(x: 14.65, y: 5.12))
        bezierPath.addLine(to: CGPoint(x: 14.65, y: 11.25))
        bezierPath.addCurve(to: CGPoint(x: 14.46, y: 11.71), controlPoint1: CGPoint(x: 14.65, y: 11.43), controlPoint2: CGPoint(x: 14.59, y: 11.58))
        bezierPath.addCurve(to: CGPoint(x: 14, y: 11.91), controlPoint1: CGPoint(x: 14.33, y: 11.85), controlPoint2: CGPoint(x: 14.18, y: 11.91))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 11.91))
        bezierPath.addCurve(to: CGPoint(x: 12.25, y: 11.71), controlPoint1: CGPoint(x: 12.53, y: 11.91), controlPoint2: CGPoint(x: 12.38, y: 11.85))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 20.49, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 14, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 14, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 36.36))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 20.49, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 14, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 14, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 29.09))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 20.49, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 14, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 14, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 20.49, y: 21.16))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 28.27, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 36.36))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 28.27, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 29.09))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 28.27, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 21.79, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 21.16))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 27.82, y: 11.71))
        bezierPath.addCurve(to: CGPoint(x: 27.62, y: 11.25), controlPoint1: CGPoint(x: 27.69, y: 11.58), controlPoint2: CGPoint(x: 27.62, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 27.62, y: 5.3))
        bezierPath.addCurve(to: CGPoint(x: 27.82, y: 4.84), controlPoint1: CGPoint(x: 27.62, y: 5.12), controlPoint2: CGPoint(x: 27.69, y: 4.97))
        bezierPath.addCurve(to: CGPoint(x: 28.27, y: 4.64), controlPoint1: CGPoint(x: 27.94, y: 4.71), controlPoint2: CGPoint(x: 28.1, y: 4.64))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 4.64))
        bezierPath.addCurve(to: CGPoint(x: 30.03, y: 4.84), controlPoint1: CGPoint(x: 29.75, y: 4.64), controlPoint2: CGPoint(x: 29.9, y: 4.71))
        bezierPath.addCurve(to: CGPoint(x: 30.22, y: 5.3), controlPoint1: CGPoint(x: 30.15, y: 4.97), controlPoint2: CGPoint(x: 30.22, y: 5.12))
        bezierPath.addLine(to: CGPoint(x: 30.22, y: 11.25))
        bezierPath.addCurve(to: CGPoint(x: 30.03, y: 11.71), controlPoint1: CGPoint(x: 30.22, y: 11.43), controlPoint2: CGPoint(x: 30.15, y: 11.58))
        bezierPath.addCurve(to: CGPoint(x: 29.57, y: 11.91), controlPoint1: CGPoint(x: 29.9, y: 11.85), controlPoint2: CGPoint(x: 29.75, y: 11.91))
        bezierPath.addLine(to: CGPoint(x: 28.27, y: 11.91))
        bezierPath.addCurve(to: CGPoint(x: 27.82, y: 11.71), controlPoint1: CGPoint(x: 28.1, y: 11.91), controlPoint2: CGPoint(x: 27.94, y: 11.85))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 35.41, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 36.36))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 30.41))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 36.36))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 35.41, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 29.09))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 22.48))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 29.09))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 35.41, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 21.16))
        bezierPath.addLine(to: CGPoint(x: 29.57, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 15.21))
        bezierPath.addLine(to: CGPoint(x: 35.41, y: 21.16))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Text Drawing
        let textRect = CGRect(x: 38, y: 0, width: 142, height: 44)
        let textTextContent = NSString(string: "View the past week")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        
        let textFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: fillColor, NSParagraphStyleAttributeName: textStyle]
        
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context!.restoreGState()
        
        if isHighlighted {
            alpha = 0.5
        } else {
            alpha = 1.0
        }
    }
 
    override var isHighlighted: Bool
        {
        didSet
        {
            super.isHighlighted = isHighlighted
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

}
