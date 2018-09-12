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
        bezierPath.move(to: CGPoint(x: 28.5, y: 11.94))
        bezierPath.addCurve(to: CGPoint(x: 27.33, y: 11.43), controlPoint1: CGPoint(x: 28.17, y: 11.6), controlPoint2: CGPoint(x: 27.78, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 25.66, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 25.66, y: 10.14))
        bezierPath.addCurve(to: CGPoint(x: 25.04, y: 8.63), controlPoint1: CGPoint(x: 25.66, y: 9.55), controlPoint2: CGPoint(x: 25.45, y: 9.05))
        bezierPath.addCurve(to: CGPoint(x: 23.57, y: 8), controlPoint1: CGPoint(x: 24.64, y: 8.21), controlPoint2: CGPoint(x: 24.14, y: 8))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 8))
        bezierPath.addCurve(to: CGPoint(x: 21.26, y: 8.63), controlPoint1: CGPoint(x: 22.16, y: 8), controlPoint2: CGPoint(x: 21.67, y: 8.21))
        bezierPath.addCurve(to: CGPoint(x: 20.64, y: 10.14), controlPoint1: CGPoint(x: 20.85, y: 9.05), controlPoint2: CGPoint(x: 20.64, y: 9.55))
        bezierPath.addLine(to: CGPoint(x: 20.64, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 15.63, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 15.63, y: 10.14))
        bezierPath.addCurve(to: CGPoint(x: 15.02, y: 8.63), controlPoint1: CGPoint(x: 15.63, y: 9.55), controlPoint2: CGPoint(x: 15.43, y: 9.05))
        bezierPath.addCurve(to: CGPoint(x: 13.54, y: 8), controlPoint1: CGPoint(x: 14.61, y: 8.21), controlPoint2: CGPoint(x: 14.12, y: 8))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 8))
        bezierPath.addCurve(to: CGPoint(x: 11.23, y: 8.63), controlPoint1: CGPoint(x: 12.13, y: 8), controlPoint2: CGPoint(x: 11.64, y: 8.21))
        bezierPath.addCurve(to: CGPoint(x: 10.62, y: 10.14), controlPoint1: CGPoint(x: 10.82, y: 9.05), controlPoint2: CGPoint(x: 10.62, y: 9.55))
        bezierPath.addLine(to: CGPoint(x: 10.62, y: 11.43))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 11.43))
        bezierPath.addCurve(to: CGPoint(x: 7.77, y: 11.94), controlPoint1: CGPoint(x: 8.49, y: 11.43), controlPoint2: CGPoint(x: 8.1, y: 11.6))
        bezierPath.addCurve(to: CGPoint(x: 7.28, y: 13.14), controlPoint1: CGPoint(x: 7.44, y: 12.28), controlPoint2: CGPoint(x: 7.28, y: 12.68))
        bezierPath.addLine(to: CGPoint(x: 7.28, y: 30.29))
        bezierPath.addCurve(to: CGPoint(x: 7.77, y: 31.49), controlPoint1: CGPoint(x: 7.28, y: 30.75), controlPoint2: CGPoint(x: 7.44, y: 31.15))
        bezierPath.addCurve(to: CGPoint(x: 8.95, y: 32), controlPoint1: CGPoint(x: 8.1, y: 31.83), controlPoint2: CGPoint(x: 8.49, y: 32))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 28.5, y: 31.49), controlPoint1: CGPoint(x: 27.78, y: 32), controlPoint2: CGPoint(x: 28.17, y: 31.83))
        bezierPath.addCurve(to: CGPoint(x: 29, y: 30.29), controlPoint1: CGPoint(x: 28.83, y: 31.15), controlPoint2: CGPoint(x: 29, y: 30.75))
        bezierPath.addLine(to: CGPoint(x: 29, y: 13.14))
        bezierPath.addCurve(to: CGPoint(x: 28.5, y: 11.94), controlPoint1: CGPoint(x: 29, y: 12.68), controlPoint2: CGPoint(x: 28.83, y: 12.28))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 30.29))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 25.57))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.71, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 8.95, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 20.43))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 12.41, y: 14.3))
        bezierPath.addCurve(to: CGPoint(x: 12.29, y: 14), controlPoint1: CGPoint(x: 12.33, y: 14.22), controlPoint2: CGPoint(x: 12.29, y: 14.12))
        bezierPath.addLine(to: CGPoint(x: 12.29, y: 10.14))
        bezierPath.addCurve(to: CGPoint(x: 12.41, y: 9.84), controlPoint1: CGPoint(x: 12.29, y: 10.03), controlPoint2: CGPoint(x: 12.33, y: 9.93))
        bezierPath.addCurve(to: CGPoint(x: 12.71, y: 9.71), controlPoint1: CGPoint(x: 12.5, y: 9.76), controlPoint2: CGPoint(x: 12.59, y: 9.71))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 9.71))
        bezierPath.addCurve(to: CGPoint(x: 13.84, y: 9.84), controlPoint1: CGPoint(x: 13.66, y: 9.71), controlPoint2: CGPoint(x: 13.75, y: 9.76))
        bezierPath.addCurve(to: CGPoint(x: 13.96, y: 10.14), controlPoint1: CGPoint(x: 13.92, y: 9.93), controlPoint2: CGPoint(x: 13.96, y: 10.03))
        bezierPath.addLine(to: CGPoint(x: 13.96, y: 14))
        bezierPath.addCurve(to: CGPoint(x: 13.84, y: 14.3), controlPoint1: CGPoint(x: 13.96, y: 14.12), controlPoint2: CGPoint(x: 13.92, y: 14.22))
        bezierPath.addCurve(to: CGPoint(x: 13.54, y: 14.43), controlPoint1: CGPoint(x: 13.75, y: 14.39), controlPoint2: CGPoint(x: 13.66, y: 14.43))
        bezierPath.addLine(to: CGPoint(x: 12.71, y: 14.43))
        bezierPath.addCurve(to: CGPoint(x: 12.41, y: 14.3), controlPoint1: CGPoint(x: 12.59, y: 14.43), controlPoint2: CGPoint(x: 12.5, y: 14.39))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 17.72, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 30.29))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 17.72, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 25.57))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 17.72, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 13.54, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 17.72, y: 20.43))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 22.73, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 30.29))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 22.73, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 25.57))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 22.73, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 18.56, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 20.43))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 22.44, y: 14.3))
        bezierPath.addCurve(to: CGPoint(x: 22.32, y: 14), controlPoint1: CGPoint(x: 22.36, y: 14.22), controlPoint2: CGPoint(x: 22.32, y: 14.12))
        bezierPath.addLine(to: CGPoint(x: 22.32, y: 10.14))
        bezierPath.addCurve(to: CGPoint(x: 22.44, y: 9.84), controlPoint1: CGPoint(x: 22.32, y: 10.03), controlPoint2: CGPoint(x: 22.36, y: 9.93))
        bezierPath.addCurve(to: CGPoint(x: 22.73, y: 9.71), controlPoint1: CGPoint(x: 22.52, y: 9.76), controlPoint2: CGPoint(x: 22.62, y: 9.71))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 9.71))
        bezierPath.addCurve(to: CGPoint(x: 23.86, y: 9.84), controlPoint1: CGPoint(x: 23.68, y: 9.71), controlPoint2: CGPoint(x: 23.78, y: 9.76))
        bezierPath.addCurve(to: CGPoint(x: 23.99, y: 10.14), controlPoint1: CGPoint(x: 23.95, y: 9.93), controlPoint2: CGPoint(x: 23.99, y: 10.03))
        bezierPath.addLine(to: CGPoint(x: 23.99, y: 14))
        bezierPath.addCurve(to: CGPoint(x: 23.86, y: 14.3), controlPoint1: CGPoint(x: 23.99, y: 14.12), controlPoint2: CGPoint(x: 23.95, y: 14.22))
        bezierPath.addCurve(to: CGPoint(x: 23.57, y: 14.43), controlPoint1: CGPoint(x: 23.78, y: 14.39), controlPoint2: CGPoint(x: 23.68, y: 14.43))
        bezierPath.addLine(to: CGPoint(x: 22.73, y: 14.43))
        bezierPath.addCurve(to: CGPoint(x: 22.44, y: 14.3), controlPoint1: CGPoint(x: 22.62, y: 14.43), controlPoint2: CGPoint(x: 22.52, y: 14.39))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 27.33, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 30.29))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 26.43))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 30.29))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 27.33, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 25.57))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 21.29))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 25.57))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 27.33, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 20.43))
        bezierPath.addLine(to: CGPoint(x: 23.57, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 16.57))
        bezierPath.addLine(to: CGPoint(x: 27.33, y: 20.43))
        bezierPath.close()
        bezierPath.miterLimit = 4;
        
        fillColor.setFill()
        bezierPath.fill()
        
        //// Text Drawing
        let textRect = CGRect(x: 20, y: -1, width: 170, height: 44)
        let textTextContent = NSString(string: "PAST WEEK")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        
        let textFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor: fillColor, NSAttributedStringKey.paragraphStyle: textStyle]
        
        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context!.restoreGState()
        
        if isHighlighted
        {
            alpha = 0.5
        }
        else
        {
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
