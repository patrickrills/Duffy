//
//  Trophy.swift
//  Duffy
//
//  Created by Patrick Rills on 5/9/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public enum Trophy: CaseIterable {
    case none, shoe, medal, award, star, rocket
    
    private func factor() -> Double {
        switch self {
        case .none:
            return 0.0
        case .shoe:
            return 1.0
        case .medal:
            return 1.25
        case .award:
            return 1.5
        case .star:
            return 1.75
        case .rocket:
            return 2.0
        }
    }
    
    public func symbol() -> String {
        switch self {
        case .none:
            return ""
        case .shoe:
            return "👟"
        case .medal:
            return "🏅"
        case .award:
            return "🏆"
        case .star:
            return "🌟"
        case .rocket:
            return "🚀"
        }
    }
    
    public static func trophy(for stepsTotal: Int) -> Trophy {
        let stepsGoal = Double(HealthCache.getStepsDailyGoal())
        let steps = Double(stepsTotal)
        
        return Trophy.allCases.reversed().filter({ return steps >= (stepsGoal * $0.factor()) }).first ?? .none
    }
}
