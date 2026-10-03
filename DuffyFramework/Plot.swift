//
//  Plot.swift
//  Duffy
//
//  Created by Patrick Rills on 10/10/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public struct Plot {
    public let points: [PlotPoint]
    public let goalY: CGFloat?
    public let averageY: CGFloat?
    public let trend: [CGPoint]?

    init(points: [PlotPoint], goalY: CGFloat?, averageY: CGFloat?, trend: [CGPoint]?) {
        self.points = points
        self.goalY = goalY
        self.averageY = averageY
        self.trend = trend
    }
    
    private static let GRAPH_MAX_FACTOR: Double = 1.05
    
    public static func generate(for dataSet: [Date : Steps], in rect: CGRect, with insets: UIEdgeInsets) -> Plot {
        return generate(for: dataSet.mapValues({ Double($0) }), goal: Double(HealthCache.dailyGoal()), in: rect, with: insets)
    }
    
    public static func generate(for dataSet: [Date : Double], goal: Double?, in rect: CGRect, with insets: UIEdgeInsets) -> Plot {
        let activeArea = CGRect(x: insets.left, y: insets.top, width: rect.width - (insets.left + insets.right), height: rect.height - (insets.top + insets.bottom))
        
        var goalLineY: CGFloat?
        var averageY: CGFloat? = nil
        var trend: [CGPoint]? = nil
        var points = [PlotPoint]()
        
        let lineDataSet = coalesce(dataSet: dataSet, for: activeArea.width)
        
        if (lineDataSet.count > 0) {
            let maxValue = lineDataSet.values.max()
            let topRange = max(maxValue!, goal ?? 0.0, 1.0) * GRAPH_MAX_FACTOR
            let minDate = lineDataSet.keys.min() ?? Date()
            let numberOfDaysInRange = max(1, minDate.differenceInDays(from: Date().previousDay()))
            let widthOfDay = CGFloat(activeArea.width) / CGFloat(numberOfDaysInRange)
            
            let translateY: (Double) -> (CGFloat) = { value in
                return activeArea.height - CGFloat((value / topRange) * Double(activeArea.height))
            }
            
            let translateX: (Date) -> (CGFloat) = { date in
                return CGFloat(abs(date.differenceInDays(from: minDate))) * widthOfDay + insets.left
            }
                        
            points = lineDataSet.reduce(into: points, { points, data in
                points.append(PlotPoint(point: CGPoint(x: translateX(data.key), y: translateY(data.value)), timestamp: data.key.timeIntervalSinceReferenceDate, value: data.value))
            }).sorted { $0.point.x < $1.point.x }
            
            goalLineY = goal.map(translateY)
            averageY = translateY(dataSet.values.mean())
            
            let xMean = points.map(\.point.x).mean()
            let yMean = points.map(\.point.y).mean()
            let calculateSlope: ([CGPoint]) -> (CGFloat) = { p in
                var slopeParts: (numerator: CGFloat, demoninator: CGFloat) = (0.0, 0.0)
                slopeParts = p.reduce(into: slopeParts, { result, point in
                    result.numerator += (point.x - xMean) * (point.y - yMean)
                    result.demoninator += pow((point.x - xMean), 2)
                })
                return slopeParts.numerator / slopeParts.demoninator
            }
            let slope = calculateSlope(points.map { $0.point })
            let yIntercept = yMean - (slope * xMean)
            trend = points.map({
                CGPoint(x: $0.point.x, y: (slope * $0.point.x) + yIntercept)
            })
        } else if goal != nil {
            //If there is no data, at least show the goal line so the chart isn't completely empty
            goalLineY = rect.size.height / 2.0
        }
        
        return Plot(points: points, goalY: goalLineY, averageY: averageY, trend: trend)
    }
    
    private static func coalesce(dataSet: [Date : Double], for width: CGFloat) -> [Date : Double] {
        guard dataSet.count > Int(width) else { return dataSet }

        let sundays = dataSet.keys.filter({ $0.isSunday() })
        var coalesced: [Date : Double] = sundays.reduce(into: [:], { result, sunday in
            let weeklyMean = dataSet.filter({ $0.key >= sunday && $0.key < sunday.dateByAdding(days: 7) }).map({ $0.value }).mean()
            let weeklyKey = sunday.dateByAdding(days: 6)
            result[weeklyKey] = weeklyMean
        })

        if let minSunday = sundays.min(),
           let minFilter = dataSet.keys.min(),
           minSunday > minFilter
        {
            coalesced[minFilter] = dataSet.filter({ $0.key >= minFilter && $0.key < minSunday }).map({ $0.value }).mean()
        }

        return coalesced
    }
}

public struct PlotPoint {
    public let point: CGPoint
    public let timestamp: TimeInterval
    public let value: Double
}
