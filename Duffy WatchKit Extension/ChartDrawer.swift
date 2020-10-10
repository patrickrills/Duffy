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
        static let GRAPH_MAX_FACTOR: Double = 1.05
    }
    
    private typealias Plot = (points: [CGPoint], goalY: CGFloat?)
    
    class func drawChart(_ data: [Date : Steps], width: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: DrawingConstants.CHART_HEIGHT)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(context!)

        let plot = ChartDrawer.plot(data, width: width)
        
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
        
        
        if let goalY = plot.goalY {
            DrawingConstants.GOAL_LINE_COLOR.setStroke()
            let line = UIBezierPath()
            line.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
            line.lineWidth = DrawingConstants.LINE_WIDTH
            line.move(to: CGPoint(x: DrawingConstants.HORIZONTAL_MARGIN, y: goalY))
            line.addLine(to: CGPoint(x: size.width - (DrawingConstants.HORIZONTAL_MARGIN * 2.0), y: goalY))
            line.stroke()
        }
        
        let cgimage = context!.makeImage()
        let uiimage = UIImage(cgImage: cgimage!)

        UIGraphicsPopContext()
        UIGraphicsEndImageContext()

        return uiimage
    }
    
    private class func plot(_ data: [Date : Steps], width: CGFloat) -> Plot {
        let activeArea = CGRect(x: DrawingConstants.GRAPH_INSETS.left, y: DrawingConstants.GRAPH_INSETS.top, width: width - (DrawingConstants.GRAPH_INSETS.left + DrawingConstants.GRAPH_INSETS.right), height: DrawingConstants.CHART_HEIGHT - (DrawingConstants.GRAPH_INSETS.top + DrawingConstants.GRAPH_INSETS.bottom))
        let goalSteps = Steps(HealthCache.dailyGoal())
        var goalLineY: CGFloat? = nil
        var points = [CGPoint]()
        
        if data.count > 0 {
            let maxSteps = data.values.max()
            let topRange = Double(max(maxSteps!, goalSteps)) * DrawingConstants.GRAPH_MAX_FACTOR
            let minDate = data.keys.min() ?? Date()
            let numberOfDaysInRange = max(1, minDate.differenceInDays(from: Date().previousDay()))
            let widthOfDay = CGFloat(activeArea.width) / CGFloat(numberOfDaysInRange)
            
            let translateY: (Steps) -> (CGFloat) = { steps in
                return activeArea.height - CGFloat(floor((Double(steps) / topRange) * Double(activeArea.height)))
            }
            
            let translateX: (Date) -> (CGFloat) = { date in
                return CGFloat(abs(date.differenceInDays(from: minDate))) * widthOfDay + DrawingConstants.GRAPH_INSETS.left
            }
            
            points = data.reduce(into: points, { points, data in
                points.append(CGPoint(x: translateX(data.key), y: translateY(data.value)))
            }).sorted { $0.x < $1.x }
            
            goalLineY = translateY(goalSteps)
        } else {
            goalLineY = DrawingConstants.CHART_HEIGHT / 2.0
        }
        
        return Plot(points: points, goalY: goalLineY)
    }
}
