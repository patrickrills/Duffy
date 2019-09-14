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
            backgroundColor = .clear
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect)
    {
        let goalSteps = HealthCache.getStepsDailyGoal()
        var lineY = rect.size.height / 2.0
        
        if (dataSet.count > 0)
        {
            let maxSteps = dataSet.values.max()
            let topRange = Double(max(maxSteps!, goalSteps)) * 1.2
            let widthOfDay = Double(rect.width) / Double(dataSet.count)
            lineY = rect.size.height - CGFloat(floor((Double(goalSteps) / topRange) * Double(rect.size.height)))
            
            let trendLine = UIBezierPath()
            
            if (widthOfDay <= 0.5)
            {
                trendLine.lineWidth = 0.5
            }
            else if (widthOfDay < 2.0)
            {
                trendLine.lineWidth = 1.0
            }
            else
            {
                trendLine.lineWidth = 2.0
            }
            
            for (index, day) in dataSet.keys.sorted().enumerated()
            {
                let stepsForDay = dataSet[day]!
                let dayY = Double(rect.size.height) - (Double(stepsForDay) / topRange) * Double(rect.size.height)
                let dayX = widthOfDay * Double(index) + floor(widthOfDay * 0.5)
                let dayPoint = CGPoint(x: dayX, y: dayY)
                
                if index == 0
                {
                    trendLine.move(to: dayPoint)
                }
                else
                {
                    trendLine.addLine(to: dayPoint)
                }
            }
            
            Globals.primaryColor().setStroke()
            trendLine.stroke()
        }
        
        let shoe = NSAttributedString(string: HealthKitService.getInstance().getAdornment(for: goalSteps), attributes: [.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        let shoeSize = shoe.size()
        
        let dotted = UIBezierPath()
        dotted.move(to: CGPoint(x: shoeSize.width + 1, y: lineY))
        dotted.addLine(to: CGPoint(x: rect.size.width, y: lineY))
        dotted.lineWidth = 1.0
        dotted.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
        Globals.lightGrayColor().setStroke()
        dotted.stroke()
        
        shoe.draw(at: CGPoint(x: 0, y: lineY - (shoeSize.height / 2.0)))
    }
}
