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
import DuffyWatchFramework

class ChartDrawer {
    
    private enum DrawingConstants {
        static let CHART_HEIGHT: CGFloat = 80.0
        static let LINE_WIDTH: CGFloat = 2.0
        static let BAR_WIDTH: CGFloat = 8.0
        static let HORIZONTAL_MARGIN: CGFloat = 4.0
        static let DASH_SIZE: Int = 2
    }
    
    class func drawChart(_ data: [Date : Steps], width: CGFloat, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: width * scale, height: DrawingConstants.CHART_HEIGHT * scale)
        let barWidth = DrawingConstants.BAR_WIDTH * scale
        let horizontalMargin = DrawingConstants.HORIZONTAL_MARGIN * scale
        let insets = UIEdgeInsets(top: 0.0, left: horizontalMargin + (barWidth / 2.0), bottom: 0.0, right: horizontalMargin + (barWidth / 2.0))
        let lineWidth = DrawingConstants.LINE_WIDTH * scale
        let goalColor = UIColor(named: "SecondaryColor")!
        let unmetGoalColor = UIColor(named: "UnmetGoalColor")!
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let plot = Plot.generate(for: data, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height), with: insets)
        
        if plot.points.count > 0 {
            let barFloor = size.height - insets.bottom
            let onlyOnePoint = plot.points.count == 1
            
            plot.points.forEach({
                let barRect = CGRect(x: (onlyOnePoint ? size.width / 2.0 : $0.x) - (barWidth / 2.0), y: $0.y, width: barWidth, height: barFloor - $0.y)
                let bar = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 4.0)
                if $0.y <= plot.goalY {
                    goalColor.setFill()
                } else {
                    unmetGoalColor.setFill()
                }
                bar.fill()
            })
        }
        
        let dashSize = CGFloat(DrawingConstants.DASH_SIZE) * scale
        let pattern: [CGFloat] = [dashSize, dashSize]
        unmetGoalColor.setStroke()
        let line = UIBezierPath()
        line.setLineDash(pattern, count: pattern.count, phase: 0.0)
        line.lineWidth = lineWidth
        line.move(to: CGPoint(x: horizontalMargin, y: plot.goalY))
        line.addLine(to: CGPoint(x: size.width - horizontalMargin, y: plot.goalY))
        line.stroke()
        
        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
}
