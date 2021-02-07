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
        static let TEXT_HEIGHT: CGFloat = 12.0
        static let TEXT_WIDTH: CGFloat = 18.0
        static let TEXT_PADDING: CGFloat = 2.0
        static let FONT_SIZE: CGFloat = 22.0
    }
    
    class func drawChart(_ data: [Date : Steps], width: CGFloat, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: width * scale, height: DrawingConstants.CHART_HEIGHT * scale)
        let barWidth = DrawingConstants.BAR_WIDTH * scale
        let horizontalMargin = DrawingConstants.HORIZONTAL_MARGIN * scale
        let textHeight = DrawingConstants.TEXT_HEIGHT * scale
        let textWidth: CGFloat = DrawingConstants.TEXT_WIDTH * scale
        let insets = UIEdgeInsets(top: 0.0, left: horizontalMargin + (barWidth / 2.0), bottom: textHeight, right: horizontalMargin + (barWidth / 2.0))
        let lineWidth = DrawingConstants.LINE_WIDTH * scale
        let goalColor = UIColor(named: "SecondaryColor")!
        let unmetGoalColor = UIColor(named: "UnmetGoalColor")!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textAttributes = [
            NSAttributedString.Key.font: Globals.roundedFont(of: DrawingConstants.FONT_SIZE, weight: .regular),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let textFormatter = Globals.summaryDateFormatter
        let textY = size.height - textHeight + DrawingConstants.TEXT_PADDING
        let plot = Plot.generate(for: data, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height), with: insets)
        
        if plot.points.count > 0 {
            let barFloor = size.height - insets.bottom
            let onlyOnePoint = plot.points.count == 1
            
            plot.points.forEach {
                let goalMet = $0.point.y <= plot.goalY
                let rawX = onlyOnePoint ? size.width / 2.0 : $0.point.x
                let barX = rawX - (barWidth / 2.0)
                
                if !goalMet {
                    let ghostBar = UIBezierPath(roundedRect: CGRect(x: barX, y: plot.goalY, width: barWidth, height: barFloor - plot.goalY), cornerRadius: barWidth / 4.0)
                    unmetGoalColor.withAlphaComponent(0.15).setFill()
                    ghostBar.fill()
                }
                
                let barRect = CGRect(x: barX, y: $0.point.y, width: barWidth, height: barFloor - $0.point.y)
                let bar = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 4.0)
                if goalMet {
                    goalColor.setFill()
                } else {
                    unmetGoalColor.setFill()
                }
                bar.fill()
                
                let dateString = textFormatter.string(from: Date(timeIntervalSinceReferenceDate: $0.timestamp)).uppercased()
                dateString.draw(with: CGRect(x: rawX - (textWidth / 2.0), y: textY, width: textWidth, height: textHeight), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
            }
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
