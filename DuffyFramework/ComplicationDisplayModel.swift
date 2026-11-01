//
//  ComplicationDisplayModel.swift
//  Duffy
//
//  Created on 6/21/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import Foundation

public struct ComplicationColorComponents {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public enum ComplicationDisplayModel {
    public static let sampleSteps: Steps = 5000
    public static let sampleGoal: Steps = 10000

    public static let blueTint = ComplicationColorComponents(red: 32.0/255.0, green: 148.0/255.0, blue: 250.0/255.0)
    public static let tealTint = ComplicationColorComponents(red: 45.0/255.0, green: 221.0/255.0, blue: 255.0/255.0)

    public static func goalReached(totalSteps: Steps, goal: Steps) -> Bool {
        return totalSteps >= goal
    }

    public static func gaugeFillFraction(totalSteps: Steps, goal: Steps) -> Float {
        guard goal > 0 else { return 0 }
        return Float(min(totalSteps, goal)) / Float(goal)
    }

    public static func graphicRectangularProgressText(totalSteps: Steps, goal: Steps) -> String {
        if goalReached(totalSteps: totalSteps, goal: goal) {
            return Trophy.trophy(for: totalSteps).symbol() + " +" + formatStepsForLarge(totalSteps - goal)
        }

        return String(format: NSLocalizedString("%@ to go", comment: ""), formatStepsForLarge(goal - totalSteps))
    }

    public static func formatStepsForLarge(_ totalSteps: Steps, useGroupingSeparator: Bool = true) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.usesGroupingSeparator = useGroupingSeparator
        if let format = numberFormatter.string(for: totalSteps) {
            return format
        }

        return "0"
    }

    public static func formatStepsForSmall(_ totalSteps: Steps) -> String {
        let moreThan1000 = totalSteps >= 1000

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = moreThan1000 ? 1 : 0
        numberFormatter.roundingMode = moreThan1000 ? .down : .ceiling

        var displaySteps: Double = Double(totalSteps)
        var suffix = ""

        if moreThan1000 {
            displaySteps /= 1000.0
            suffix = "k"
        }

        if let format = numberFormatter.string(for: displaySteps) {
            return String(format: "%@%@", format, suffix)
        }

        return "0"
    }

    public static func formatStepsForVerySmall(_ totalSteps: Steps) -> String {
        if totalSteps >= 1000 {
            let displaySteps: Double = Double(totalSteps) / 1000.0
            let numberFormatter = NumberFormatter()
            numberFormatter.roundingMode = .down
            numberFormatter.numberStyle = .decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = totalSteps >= 10000 ? 0 : 1
            if let format = numberFormatter.string(for: displaySteps) {
                return format.count <= 2 ? String(format: "%@k", format) : format
            }
        }

        return totalSteps > 0 ? "<1k" : "0"
    }
}
