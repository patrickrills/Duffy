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
    
    func displayName() -> String { //TODO: Japanese translations
        switch self {
        case .actualDataLine:
            return "Detail"
        case .trendLine:
            return "Trend"
        case .averageIndicator:
            return "Average"
        case .goalIndicator:
            return "Goal"
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
    
    func displayName() -> String { //TODO: Japanese translations
        switch self {
        case .actual:
            return HistoryTrendChartOption.actualDataLine.displayName()
        case .trend:
            return HistoryTrendChartOption.trendLine.displayName()
        case .both:
            return String(format: "%@ & %@", HistoryTrendChartLineOption.actual.displayName(), HistoryTrendChartLineOption.trend.displayName())
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
