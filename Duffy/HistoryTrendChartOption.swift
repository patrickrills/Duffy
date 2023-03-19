//
//  HistoryTrendChartOption.swift
//  Duffy
//
//  Created by Patrick Rills on 8/22/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

enum HistoryTrendChartOption: String, CaseIterable {
    case actualDataLine = "actualDataLine"
    case trendLine = "trendLine"
    case goalIndicator = "goalIndicator"
    case averageIndicator = "averageIndicator"
    
    func displayName() -> String {
        switch self {
        case .actualDataLine:
            return NSLocalizedString("Detail", comment: "Option describing a graph line that plots every data point")
        case .trendLine:
            return NSLocalizedString("Trend", comment: "Option describing a graph line that shows the trend of your data but not every point")
        case .averageIndicator:
            return NSLocalizedString("Average", comment: "Option describing whether or not to show an indicator on the graph showing where the average of data points is")
        case .goalIndicator:
            return NSLocalizedString("Goal", comment: "Option describing whether or not to show an indicator on the graph showing where your goal is")
        }
    }
    
    func symbolName() -> String {
        switch self {
        case .actualDataLine:
            if #available(iOS 15.0, *) {
                return "chart.line.uptrend.xyaxis"
            }
            
            return "waveform.path.ecg"
            
        case .trendLine:
            if #available(iOS 16.0, *) {
                return "chart.line.flattrend.xyaxis"
            }
            
            return "line.diagonal.arrow"
            
        case .averageIndicator:
            return "divide.square"
            
        case .goalIndicator:
            if #available(iOS 16.0, *) {
                return "medal"
            }
            
            return "figure.walk"
            
        }
    }
    
    func isEnabled() -> Bool {
        guard let settingValue = UserDefaults.standard.value(forKey: self.rawValue) as? Bool else { return true } //If value has never been set, return true
        return settingValue
    }
    
    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: self.rawValue)
    }
}

enum HistoryTrendChartLineOption: CaseIterable {
    case actual, trend, both
    
    func displayName() -> String {
        switch self {
        case .actual:
            return HistoryTrendChartOption.actualDataLine.displayName()
        case .trend:
            return HistoryTrendChartOption.trendLine.displayName()
        case .both:
            return String(format: NSLocalizedString("%@ & %@", comment: "Concatenate to options together with 'and'"), HistoryTrendChartLineOption.actual.displayName(), HistoryTrendChartLineOption.trend.displayName())
        }
    }
    
    func isEnabled() -> Bool {
        return self == HistoryTrendChartLineOption.currentValue()
    }
    
    func setEnabled() {
        guard !isEnabled() else { return }
        
        var actualEnabled = false
        var trendEnabled = false
        
        switch self {
        case .actual:
            actualEnabled = true
        case .trend:
            trendEnabled = true
        case .both:
            actualEnabled = true
            trendEnabled = true
        }
        
        HistoryTrendChartOption.actualDataLine.setEnabled(actualEnabled)
        HistoryTrendChartOption.trendLine.setEnabled(trendEnabled)
    }
    
    static func currentValue() -> HistoryTrendChartLineOption {
        switch (HistoryTrendChartOption.actualDataLine.isEnabled(), HistoryTrendChartOption.trendLine.isEnabled()) {
        case (true, false),
             (false, false):
            return .actual
        case (false, true):
            return .trend
        case (true, true):
            return .both
        }
    }
}
