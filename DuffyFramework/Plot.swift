//
//  Plot.swift
//  Duffy
//
//  Created by Patrick Rills on 10/10/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public struct Plot {
    public let points: [CGPoint]
    public let goalY: CGFloat
    public let averageY: CGFloat?
    public let trend: [CGPoint]?

    init(points: [CGPoint], goalY: CGFloat, averageY: CGFloat?, trend: [CGPoint]?) {
        self.points = points
        self.goalY = goalY
        self.averageY = averageY
        self.trend = trend
    }
    
    private static let GRAPH_MAX_FACTOR: Double = 1.05
    
    public static func generate(for dataSet: [Date : Steps], in rect: CGRect, with insets: UIEdgeInsets) -> Plot {
        let activeArea = CGRect(x: insets.left, y: insets.top, width: rect.width - (insets.left + insets.right), height: rect.height - (insets.top + insets.bottom))
        
        let goalSteps = HealthCache.dailyGoal()
        var goalLineY: CGFloat
        var averageY: CGFloat? = nil
        var trend: [CGPoint]? = nil
        var points = [CGPoint]()
        
        let lineDataSet = coalesce(dataSet: dataSet, for: activeArea.width)
        
        if (lineDataSet.count > 0) {
            let maxSteps = lineDataSet.values.max()
            let topRange = Double(max(maxSteps!, goalSteps)) * GRAPH_MAX_FACTOR
            let minDate = lineDataSet.keys.min() ?? Date()
            let numberOfDaysInRange = max(1, minDate.differenceInDays(from: Date().previousDay()))
            let widthOfDay = CGFloat(activeArea.width) / CGFloat(numberOfDaysInRange)
            
            let translateY: (Steps) -> (CGFloat) = { steps in
                return activeArea.height - CGFloat(floor((Double(steps) / topRange) * Double(activeArea.height)))
            }
            
            let translateX: (Date) -> (CGFloat) = { date in
                return CGFloat(abs(date.differenceInDays(from: minDate))) * widthOfDay + insets.left
            }
                        
            points = lineDataSet.reduce(into: points, { points, data in
                points.append(CGPoint(x: translateX(data.key), y: translateY(data.value)))
            }).sorted { $0.x < $1.x }
            
            goalLineY = translateY(goalSteps)
            averageY = translateY(Steps(dataSet.values.mean()))
            
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
        } else {
            //If there is no data, at least show the goal line so the chart isn't completely empty
            goalLineY = rect.size.height / 2.0
        }
        
        return Plot(points: points, goalY: goalLineY, averageY: averageY, trend: trend)
    }
    
    private static func coalesce(dataSet: [Date : Steps], for width: CGFloat) -> [Date : Steps] {
        guard dataSet.count > Int(width) else { return dataSet }

        let sundays = dataSet.keys.filter({ $0.isSunday() })
        var coalesced: [Date : Steps] = sundays.reduce(into: [:], { result, sunday in
            let weeklyMean = dataSet.filter({ $0.key >= sunday && $0.key < sunday.dateByAdding(days: 7) }).map({ $0.value }).mean()
            let weeklyKey = sunday.dateByAdding(days: 6)
            result[weeklyKey] = Steps(weeklyMean)
        })

        if let minSunday = sundays.min(),
           let minFilter = dataSet.keys.min(),
           minSunday > minFilter
        {
            coalesced[minFilter] = Steps(dataSet.filter({ $0.key >= minFilter && $0.key < minSunday }).map({ $0.value }).mean())
        }

        return coalesced
    }
}
