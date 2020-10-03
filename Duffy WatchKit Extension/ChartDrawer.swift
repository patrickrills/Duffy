//
//  ChartDrawer.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 10/3/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation
import CoreGraphics
import WatchKit

class ChartDrawer {
    
    class func drawChart(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let lineColor = UIColor(named: "PrimaryColor")!
        lineColor.setStroke()
        
        let line = UIBezierPath()
        line.lineWidth = 2.0
        line.move(to: CGPoint(x: 4, y: size.height / 2.0))
        line.addLine(to: CGPoint(x: size.width - 8, y: size.height / 2.0))
        line.stroke()

        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
    
}
