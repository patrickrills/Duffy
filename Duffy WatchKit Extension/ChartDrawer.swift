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
    
    private enum Constants {
        static let CHART_HEIGHT: CGFloat = 80.0
        static let LINE_WIDTH: CGFloat = 2.0
        static let HORIZONTAL_MARGIN: CGFloat = 4.0
    }
    
    class func drawChart(width: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: Constants.CHART_HEIGHT)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let lineColor = UIColor(named: "PrimaryColor")!
        lineColor.setStroke()
        
        let line = UIBezierPath()
        line.lineWidth = Constants.LINE_WIDTH
        line.move(to: CGPoint(x: Constants.HORIZONTAL_MARGIN, y: size.height / 2.0))
        line.addLine(to: CGPoint(x: size.width - (Constants.HORIZONTAL_MARGIN * 2.0), y: size.height / 2.0))
        line.stroke()

        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
    
}
