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
    
    var dataSet : [Date : Steps] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let graphPlot = Plot.generate(for: dataSet, in: rect, with: DrawingConstants.GRAPH_INSETS)
        drawDataLine(with: graphPlot, in: rect)
        drawTrendLine(with: graphPlot, in: rect)
        drawGoalLine(with: graphPlot, in: rect)
        drawAverageLine(with: graphPlot, in: rect)
    }
    
    private func drawDataLine(with plot: Plot, in rect: CGRect) {
        guard HistoryTrendChartOption.actualDataLine.isEnabled() else { return }
        
        if plot.points.count > 0 {
            if plot.points.count == 1, let onlyPoint = plot.points.first {
                let singlePoint = UIBezierPath(ovalIn: CGRect(x: rect.midX, y: onlyPoint.point.y - 4.0, width: 8.0, height: 8.0))
                Globals.primaryColor().setFill()
                singlePoint.fill()
            } else {
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
                        dataLine.move(to: $0.point)
                    } else {
                        dataLine.addLine(to: $0.point)
                    }
                })
                
                Globals.primaryColor().setStroke()
                dataLine.stroke()
            }
        }
    }
    
    private func drawTrendLine(with plot: Plot, in rect: CGRect) {
        guard HistoryTrendChartOption.trendLine.isEnabled(),
            let trendPoints = plot.trend,
            trendPoints.count > 0
        else {
            return
        }
        
        let trendLine = UIBezierPath()
        trendLine.lineWidth = 2.5
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
        guard HistoryTrendChartOption.goalIndicator.isEnabled() else { return }
        let goalY = plot.goalY
        let shoe = NSAttributedString(string: Trophy.shoe.symbol(), attributes: [.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        let shoeSize = shoe.size()
        let shoeOrigin = CGPoint(x: DrawingConstants.PADDING, y: goalY - (shoeSize.height / 2.0))
        drawDottedLine(at: goalY, in: Globals.lightGrayColor())
        shoe.draw(at: shoeOrigin)
    }
    
    private func drawAverageLine(with plot: Plot, in rect: CGRect) {
        guard HistoryTrendChartOption.averageIndicator.isEnabled(), let averageY = plot.averageY else { return }
        let avgText = NSAttributedString(string: NSLocalizedString("avg", comment: "1 to 3 character abbreviation of 'average'"), attributes: [.font : UIFont.systemFont(ofSize: 12.0), .foregroundColor: Globals.averageColor()])
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
