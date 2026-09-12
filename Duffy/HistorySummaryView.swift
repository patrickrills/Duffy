//
//  HistorySummaryView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/12/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import SwiftUI
import DuffyFramework

struct HistorySummaryView: View {
    
    private enum Constants {
        static let TITLE_FONT_SIZE: CGFloat = 15.0
        static let AVERAGE_FONT_SIZE: CGFloat = 28.0
        static let TOTAL_FONT_SIZE: CGFloat = 17.0
        static let EMOJI_FONT_SIZE: CGFloat = 30.0
        static let EMOJI_WIDTH: CGFloat = 48.0
        static let EMOJI_HEIGHT: CGFloat = 36.0
        static let EXTREME_VALUE_FONT_SIZE: CGFloat = 15.0
        static let EXTREME_DATE_FONT_SIZE: CGFloat = 13.0
        static let EXTREME_SPACING: CGFloat = 2.0
        static let EXTREMES_MARGIN: CGFloat = 10.0
        static let BAR_HEIGHT: CGFloat = 8.0
        static let DOT_SIZE: CGFloat = 20.0
        static let DOT_PADDING: CGFloat = 2.0
        static let SEPARATOR_HEIGHT: CGFloat = 8.0
        static let SEPARATOR_MARGIN: CGFloat = 8.0
        static let MINIMUM_EMOJI: String = "😐"
        static let MAXIMUM_EMOJI: String = "😎"
    }
    
    //MARK: Properties
    
    let values: [Date : Double]
    let dataType: HistoryDataType
    
    @Environment(\.displayScale) private var displayScale
    
    //MARK: Body
    
    var body: some View {
        let summary = stats
        
        VStack(alignment: .leading, spacing: 0.0) {
            Text(NSLocalizedString("Daily Average", comment: ""))
                .font(.system(size: Constants.TITLE_FONT_SIZE))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            HStack(alignment: .lastTextBaseline) {
                Text(dataType.format(summary.average))
                    .font(.system(size: Constants.AVERAGE_FONT_SIZE, weight: .bold))
                    .foregroundStyle(Color(uiColor: Globals.averageColor()))
                
                Spacer()
                
                Text(String(format: NSLocalizedString("%@ total", comment: ""), dataType.format(summary.total)))
                    .font(.system(size: Constants.TOTAL_FONT_SIZE))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            extremes(summary)
                .padding(.top, Constants.EXTREMES_MARGIN)
            
            if let overDaysCount = summary.overDaysCount {
                separator
                    .padding(.top, Constants.SEPARATOR_MARGIN)
                
                Text(overText(for: overDaysCount))
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .label.withAlphaComponent(0.7)))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Constants.SEPARATOR_MARGIN)
            }
        }
    }
    
    //MARK: Minimum, maximum and the average indicator
    
    private func extremes(_ stats: Stats) -> some View {
        HStack(alignment: .top, spacing: Constants.EXTREME_SPACING) {
            extreme(Constants.MINIMUM_EMOJI, stats.min)
            
            averageBar(at: averagePosition(stats))
                .frame(height: Constants.EMOJI_HEIGHT)
            
            extreme(Constants.MAXIMUM_EMOJI, stats.max)
        }
    }
    
    private func extreme(_ emoji: String, _ extreme: Extreme?) -> some View {
        VStack(spacing: 0.0) {
            Text(emoji)
                .font(.system(size: Constants.EMOJI_FONT_SIZE))
                .frame(width: Constants.EMOJI_WIDTH, height: Constants.EMOJI_HEIGHT)
            
            if let extreme = extreme {
                Text(dataType.format(extreme.value))
                    .font(.system(size: Constants.EXTREME_VALUE_FONT_SIZE, weight: .medium))
                    .foregroundStyle(Color(uiColor: .label))
                
                Text(Globals.shortDateFormatter().string(from: extreme.key).uppercased())
                    .font(.system(size: Constants.EXTREME_DATE_FONT_SIZE))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    private func averageBar(at position: Double?) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .systemGray4))
                    .frame(height: Constants.BAR_HEIGHT)
                
                if let position = position {
                    averageDot
                        .offset(x: (geometry.size.width * position) - (Constants.BAR_HEIGHT / 2.0))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var averageDot: some View {
        Circle()
            .fill(Color(uiColor: .secondarySystemGroupedBackground))
            .frame(width: Constants.DOT_SIZE, height: Constants.DOT_SIZE)
            .overlay(
                Circle()
                    .fill(Color(uiColor: Globals.averageColor()))
                    .padding(Constants.DOT_PADDING)
            )
    }
    
    private var separator: some View {
        Color(uiColor: Globals.separatorColor())
            .frame(height: 1.0 / displayScale)
            .frame(height: Constants.SEPARATOR_HEIGHT)
    }
    
    //MARK: Summary calculations
    
    private typealias Extreme = (key: Date, value: Double)
    
    private struct Stats {
        let average: Double
        let total: Double
        let min: Extreme?
        let max: Extreme?
        let overDaysCount: UInt?
    }
    
    private var stats: Stats {
        var overDaysCount: UInt?
        
        if dataType.supportsGoal {
            let goal = Double(HealthCache.dailyGoal())
            overDaysCount = UInt(values.values.filter({ $0 >= goal }).count)
        }
        
        return Stats(average: values.values.mean(),
                     total: values.values.sum(),
                     min: values.count > 1 ? values.min(by: { $0.value < $1.value }) : nil,
                     max: values.count > 1 ? values.max(by: { $0.value < $1.value }) : nil,
                     overDaysCount: overDaysCount)
    }
    
    private func averagePosition(_ stats: Stats) -> Double? {
        guard let min = stats.min,
              let max = stats.max,
              stats.average > 0,
              case let span = max.value - min.value,
              span > 0
        else {
            return nil
        }
        
        return (stats.average - min.value) / span
    }
    
    private func overText(for overCount: UInt) -> String {
        let startDate = values.keys.min() ?? Date().previousDay()
        let numberOfDays = startDate.differenceInDays(from: Date())
        let percentOfDays = Double(overCount) / Double(numberOfDays)
        let countString = NSLocalizedString("summary_goal_count", comment: "")
        
        return String.localizedStringWithFormat(countString, overCount, Globals.stepsFormatter().string(for: numberOfDays)!, Globals.percentFormatter().string(for: percentOfDays)!)
    }
}
