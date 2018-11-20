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
    var dataSet : [Date : Int] = [:]
    {
        didSet
        {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect)
    {
        var lineY = rect.size.height / 2.0
        
        if (dataSet.count > 0)
        {
            let maxSteps = dataSet.values.max()
            let goalSteps = HealthCache.getStepsDailyGoal()
            let topRange = Double(max(maxSteps!, goalSteps)) * 1.2
            lineY = rect.size.height - CGFloat(floor((Double(goalSteps) / topRange) * Double(rect.size.height)))
            
            Globals.primaryColor().setFill()
            
            for (index, day) in dataSet.keys.sorted().enumerated()
            {
                let stepsForDay = dataSet[day]!
                let dotY = rect.size.height - CGFloat(floor((Double(stepsForDay) / topRange) * Double(rect.size.height)))
                let dotX = CGFloat(floor(Double(rect.width) / Double(dataSet.count))) * CGFloat(index)
                let path = UIBezierPath(arcCenter: CGPoint(x: dotX, y: dotY), radius: 4.0, startAngle: 0, endAngle: 360, clockwise: true)
                path.fill()
            }
        }
        
        let dotted = UIBezierPath()
        dotted.move(to: CGPoint(x: 0, y: lineY))
        dotted.addLine(to: CGPoint(x: rect.size.width, y: lineY))
        dotted.lineWidth = 1.0
        dotted.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        Globals.veryLightGrayColor().setStroke()
        dotted.stroke()
    }

}
