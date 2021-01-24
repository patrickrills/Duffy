//
//  GoalInstructions.swift
//  Duffy
//
//  Created by Patrick Rills on 1/24/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import DuffyFramework

enum GoalInstructions: CaseIterable {
    case step1, step2, step3, step4
    
    static func title() -> String {
        return NSLocalizedString("Change Your Goal", comment: "")
    }
    
    static func headline() -> String {
        return String(format: NSLocalizedString("This guide describes how to change your daily steps goal (currently %@ steps). Your goal can only be changed from the Duffy Apple Watch app.", comment: ""), formattedGoal())
    }
    
    func text(useLegacyInstructions: Bool) -> String {
        switch self {
        case .step1:
            return NSLocalizedString("From the Today view of the Apple Watch app, scroll the screen by swiping upward your finger or turning the digital crown.", comment: "")
        case .step2:
            return NSLocalizedString("Tap the 'Change Goal' button that appears at the bottom of the screen.", comment: "")
        case .step3:
            return useLegacyInstructions
                ? NSLocalizedString("Select a new goal by swiping with your finger or turning the digital crown. Then tap the 'Set Goal' button to save it.", comment: "")
                : NSLocalizedString("Select a new goal by tapping the plus (+) or minus (-) buttons or turning the digital crown. Then tap the 'Set Goal' button to save it.", comment: "")
        case .step4:
            return String(format: NSLocalizedString("When you've reached your goal, you'll earn a trophy based on how many steps you've taken beyond your goal (%@).", comment: "Placeholder is a number of steps: ie 10,000"), Self.formattedGoal())
        }
    }
    
    private static func formattedGoal() -> String {
        return Globals.stepsFormatter().string(for: HealthCache.dailyGoal())!
    }
}
