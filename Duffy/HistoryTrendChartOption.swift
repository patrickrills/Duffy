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
            return "Data Line"
        case .trendLine:
            return "Trend Line"
        case .averageIndicator:
            return "Average Indicator"
        case .goalIndicator:
            return "Goal Indicator"
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
