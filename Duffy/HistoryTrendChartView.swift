//
//  HistoryTrendChartView.swift
//  Duffy
//
//  Created by Patrick Rills on 11/19/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HistoryTrendChartView: UIView
{
    private enum DrawingConstants {
        static let PADDING: CGFloat = 8.0
        static let LABEL_WIDTH: CGFloat = 20.0
        static let DOTTED_LINE_MARGIN: CGFloat = (PADDING + LABEL_WIDTH + 2.0) //padding + Label width + extra so the line doesn't touch the label
        static let GRAPH_INSETS = UIEdgeInsets(top: 0.0, left: PADDING + 15.0, bottom: 0.0, right: PADDING + 15.0)
    }
    
    typealias Plot = (points: [CGPoint], goalY: CGFloat, averageY: CGFloat?, trend: [CGPoint]?)
    
    var dataSet : [Date : Int] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let graphPlot = plot(in: rect)
        drawDataLine(with: graphPlot, in: rect)
        drawTrendLine(with: graphPlot, in: rect)
        drawGoalLine(with: graphPlot, in: rect)
        drawAverageLine(with: graphPlot, in: rect)
    }
    
    private func plot(in rect: CGRect) -> Plot {
        let activeArea = CGRect(x: DrawingConstants.GRAPH_INSETS.left, y: DrawingConstants.GRAPH_INSETS.top, width: rect.width - (DrawingConstants.GRAPH_INSETS.left + DrawingConstants.GRAPH_INSETS.right), height: rect.height - (DrawingConstants.GRAPH_INSETS.top + DrawingConstants.GRAPH_INSETS.bottom))
        let goalSteps = HealthCache.getStepsDailyGoal()
        var goalLineY: CGFloat = rect.size.height / 2.0
        var averageY: CGFloat? = nil
        var trend: [CGPoint]? = nil
        var points = [CGPoint]()
        
        if (dataSet.count > 0) {
            let maxSteps = dataSet.values.max()
            let topRange = Double(max(maxSteps!, goalSteps)) * 1.2
            let widthOfDay = Double(activeArea.width) / Double(dataSet.count)
            
            let translateY: (Int) -> (CGFloat) = { steps in
                return activeArea.height - CGFloat(floor((Double(steps) / topRange) * Double(activeArea.height)))
            }
            
            goalLineY = translateY(goalSteps)
            
            for (index, day) in dataSet.keys.sorted().enumerated() {
                let stepsForDay = dataSet[day]!
                let dayY: Double = Double(translateY(stepsForDay))
                let dayX: Double = (widthOfDay * Double(index) + floor(widthOfDay * 0.5)) + Double(DrawingConstants.GRAPH_INSETS.left)
                points.append(CGPoint(x: dayX, y: dayY))
            }
            
            //TODO: check to see if average line option is enabled
            if DebugService.isDebugModeEnabled() {
                averageY = translateY(Int(dataSet.values.mean()))
            }
            
            //TODO: check to see if trend line option is enabled
            if DebugService.isDebugModeEnabled() {
                let xMean = points.map(\.x).mean()
                let yMean = points.map(\.y).mean()
                let calculateSlope: ([CGPoint]) -> (CGFloat) = { p in
                    var slopeParts: (numerator: CGFloat, demoninator: CGFloat) = (0.0, 0.0)
                    slopeParts = p.reduce(into: slopeParts, { result, point in
                        result.numerator += (point.x - xMean) * (point.y - yMean)
                        result.demoninator += pow((point.x - xMean), 2)
                    })
                    return slopeParts.numerator / slopeParts.demoninator
                }
                let slope = calculateSlope(points)
                let yIntercept = yMean - (slope * xMean)
                trend = points.map({
                    CGPoint(x: $0.x, y: (slope * $0.x) + yIntercept)
                })
            }
        }
        
        return Plot(points: points, goalY: goalLineY, averageY: averageY, trend: trend)
    }
    
    private func drawDataLine(with plot: Plot, in rect: CGRect) {
        
        //TODO: check to see if data line option is enabled
        
        if plot.points.count > 0 {
            let dataLine = UIBezierPath()
            let xWidth = rect.width / CGFloat(plot.points.count)
    
            if (xWidth <= 0.5) {
                dataLine.lineWidth = 0.5
            } else if (xWidth < 2.0) {
                dataLine.lineWidth = 1.0
            } else {
                dataLine.lineWidth = 2.0
            }
            
            plot.points.forEach({
                if dataLine.isEmpty {
                    dataLine.move(to: $0)
                } else {
                    dataLine.addLine(to: $0)
                }
            })
            
            Globals.primaryColor().setStroke()
            dataLine.stroke()
        }
    }
    
    private func drawTrendLine(with plot: Plot, in rect: CGRect) {
        guard let trendPoints = plot.trend, trendPoints.count > 0 else { return }
        
        let trendLine = UIBezierPath()
        trendLine.lineWidth = 1.5
        trendPoints.forEach({
            if trendLine.isEmpty {
                trendLine.move(to: $0)
            } else {
                trendLine.addLine(to: $0)
            }
        })
        Globals.trendColor().setStroke()
        trendLine.stroke()
    }
    
    private func drawGoalLine(with plot: Plot, in rect: CGRect) {
        let shoe = NSAttributedString(string: Trophy.shoe.symbol(), attributes: [.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        let shoeSize = shoe.size()
        let shoeOrigin = CGPoint(x: DrawingConstants.PADDING, y: plot.goalY - (shoeSize.height / 2.0))
        drawDottedLine(at: plot.goalY, in: Globals.lightGrayColor())
        shoe.draw(at: shoeOrigin)
    }
    
    private func drawAverageLine(with plot: Plot, in rect: CGRect) {
        guard let averageY = plot.averageY else { return }
        //TODO: find japanese translation of average
        let avgText = NSAttributedString(string: "avg", attributes: [.font : UIFont.systemFont(ofSize: 12.0), .foregroundColor: Globals.averageColor()])
        let avgTextOrigin = CGPoint(x: rect.width - DrawingConstants.LABEL_WIDTH - DrawingConstants.PADDING, y: averageY - (avgText.size().height / 2.0) - 1.0)
        drawDottedLine(at: averageY, in: Globals.averageColor())
        avgText.draw(at: avgTextOrigin)
    }
    
    private func drawDottedLine(at y: CGFloat, in color: UIColor) {
        let dotted = UIBezierPath()
        dotted.move(to: CGPoint(x: DrawingConstants.DOTTED_LINE_MARGIN, y: y))
        dotted.addLine(to: CGPoint(x: self.frame.size.width - DrawingConstants.DOTTED_LINE_MARGIN, y: y))
        dotted.lineWidth = 1.0
        dotted.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        color.setStroke()
        dotted.stroke()
    }
}
