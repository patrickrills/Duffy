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
        static let HORIZONTAL_MARGIN: CGFloat = 4.0
        static let GRAPH_INSETS = UIEdgeInsets(top: 0.0, left: HORIZONTAL_MARGIN, bottom: 0.0, right: HORIZONTAL_MARGIN)
        static let GOAL_LINE_COLOR: UIColor = .lightGray
    }
    
    class func drawChart(_ data: [Date : Steps], width: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: DrawingConstants.CHART_HEIGHT)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let plot = Plot.generate(for: data, in: CGRect(x: 0.0, y: 0.0, width: width, height: DrawingConstants.CHART_HEIGHT), with: DrawingConstants.GRAPH_INSETS)
        
        if plot.points.count > 0 {
            let lineColor = UIColor(named: "PrimaryColor")!
            
            if plot.points.count == 1, let onlyPoint = plot.points.first {
                let singlePoint = UIBezierPath(ovalIn: CGRect(x: width / 2.0, y: onlyPoint.y - 4.0, width: 8.0, height: 8.0))
                lineColor.setFill()
                singlePoint.fill()
            } else {
                let dataLine = UIBezierPath()
                dataLine.lineWidth = DrawingConstants.LINE_WIDTH
                
                plot.points.forEach({
                    if dataLine.isEmpty {
                        dataLine.move(to: $0)
                    } else {
                        dataLine.addLine(to: $0)
                    }
                })
                
                lineColor.setStroke()
                dataLine.stroke()
            }
        }
        
        DrawingConstants.GOAL_LINE_COLOR.setStroke()
        let line = UIBezierPath()
        line.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        line.lineWidth = DrawingConstants.LINE_WIDTH
        line.move(to: CGPoint(x: DrawingConstants.HORIZONTAL_MARGIN, y: plot.goalY))
        line.addLine(to: CGPoint(x: size.width - (DrawingConstants.HORIZONTAL_MARGIN * 2.0), y: plot.goalY))
        line.stroke()
        
        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
}
