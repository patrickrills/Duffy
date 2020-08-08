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
    var dataSet : [Date : Int] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    typealias Plot = (points: [CGPoint], goalY: CGFloat, averageY: CGFloat?)
    
    override func draw(_ rect: CGRect) {
        let graphPlot = plot(in: rect)
        drawDataLine(with: graphPlot, in: rect)
        drawGoalLine(with: graphPlot, in: rect)
    }
    
    private func plot(in rect: CGRect) -> Plot {
        let goalSteps = HealthCache.getStepsDailyGoal()
        var goalLineY: CGFloat = rect.size.height / 2.0
        let averageY: CGFloat? = nil
        var points = [CGPoint]()
        
        if (dataSet.count > 0) {
            let maxSteps = dataSet.values.max()
            let topRange = Double(max(maxSteps!, goalSteps)) * 1.2
            let widthOfDay = Double(rect.width) / Double(dataSet.count)
            goalLineY = rect.size.height - CGFloat(floor((Double(goalSteps) / topRange) * Double(rect.size.height)))
            
            for (index, day) in dataSet.keys.sorted().enumerated() {
                let stepsForDay = dataSet[day]!
                let dayY = Double(rect.size.height) - (Double(stepsForDay) / topRange) * Double(rect.size.height)
                let dayX = widthOfDay * Double(index) + floor(widthOfDay * 0.5)
                points.append(CGPoint(x: dayX, y: dayY))
            }
        }
        
        return Plot(points: points, goalY: goalLineY, averageY: averageY)
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
    
    private func drawGoalLine(with plot: Plot, in rect: CGRect) {
        let shoe = NSAttributedString(string: Trophy.shoe.symbol(), attributes: [.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        let shoeSize = shoe.size()
        
        let dotted = UIBezierPath()
        dotted.move(to: CGPoint(x: shoeSize.width + 1, y: plot.goalY))
        dotted.addLine(to: CGPoint(x: rect.size.width, y: plot.goalY))
        dotted.lineWidth = 1.0
        dotted.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        Globals.lightGrayColor().setStroke()
        dotted.stroke()
        
        shoe.draw(at: CGPoint(x: 0, y: plot.goalY - (shoeSize.height / 2.0)))
    }
}
