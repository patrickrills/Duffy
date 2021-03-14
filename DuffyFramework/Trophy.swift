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
    
    public func factor() -> Double {
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
    
    public func description() -> String {
        switch self {
        case .shoe:
            return NSLocalizedString("Reached your goal", comment: "")
        case .medal:
            return NSLocalizedString("25% over your goal", comment: "")
        case .award:
            return NSLocalizedString("50% over your goal", comment: "")
        case .star:
            return NSLocalizedString("75% over your goal", comment: "")
        case .rocket:
            return DebugService.isDebugModeEnabled()
                ? NSLocalizedString("Get the rocket trophy when your step count is 2x your goal.", comment: "")
                : NSLocalizedString("Double your goal", comment: "")
        default:
            return ""
        }
    }
    
    public func stepsRequired() -> Steps {
        let stepsGoal = Double(HealthCache.dailyGoal())
        return Steps(ceil(stepsGoal * self.factor()))
    }
    
    public static func trophy(for stepsTotal: Steps) -> Trophy {
        let stepsGoal = Double(HealthCache.dailyGoal())
        let steps = Double(stepsTotal)
        
        return Trophy.allCases.reversed().filter({ return steps >= (stepsGoal * $0.factor()) }).first ?? .none
    }
}
