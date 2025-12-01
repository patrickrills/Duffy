//
//  ComplicationViews.swift
//  Duffy WatchKit Extension
//
//  Created by Devin AI on 12/1/24.
//  Copyright © 2024 Big Blue Fly. All rights reserved.
//

import SwiftUI
import ClockKit
import DuffyWatchFramework

// MARK: - Shared Data Model

struct ComplicationData {
    let steps: Steps
    let goal: Steps
    let formattedSteps: String
    let formattedStepsShort: String
    let formattedStepsVeryShort: String
    let formattedGoal: String
    let progress: Float
    let goalReached: Bool
    let trophy: Trophy
    let stepsToGo: Steps
    let stepsOver: Steps
    
    init(steps: Steps, goal: Steps, formatter: StepsFormatter) {
        self.steps = steps
        self.goal = goal
        self.formattedSteps = formatter.formatLarge(steps)
        self.formattedStepsShort = formatter.formatSmall(steps)
        self.formattedStepsVeryShort = formatter.formatVerySmall(steps)
        self.formattedGoal = formatter.formatVerySmall(goal)
        self.progress = Float(min(steps, goal)) / Float(goal)
        self.goalReached = steps >= goal
        self.trophy = Trophy.trophy(for: steps)
        self.stepsToGo = goal > steps ? goal - steps : 0
        self.stepsOver = steps > goal ? steps - goal : 0
    }
}

// MARK: - Steps Formatter Protocol

struct StepsFormatter {
    func formatLarge(_ totalSteps: Steps, useGroupingSeparator: Bool = true) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.usesGroupingSeparator = useGroupingSeparator
        if let format = numberFormatter.string(for: totalSteps) {
            return format
        }
        return "0"
    }
    
    func formatSmall(_ totalSteps: Steps) -> String {
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
    
    func formatVerySmall(_ totalSteps: Steps) -> String {
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

// MARK: - Color Constants

enum ComplicationColors {
    static let blueTint = Color(red: 32.0/255.0, green: 148.0/255.0, blue: 250.0/255.0)
    static let tealTint = Color(red: 45.0/255.0, green: 221.0/255.0, blue: 255.0/255.0)
    
    static let blueTintUI = UIColor(red: 32.0/255.0, green: 148.0/255.0, blue: 250.0/255.0, alpha: 1)
    static let tealTintUI = UIColor(red: 45.0/255.0, green: 221.0/255.0, blue: 255.0/255.0, alpha: 1)
}

// MARK: - Progress Ring View

@available(watchOS 7.0, *)
struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color
    
    init(progress: Double, lineWidth: CGFloat = 4.0, ringColor: Color = .white, backgroundColor: Color = Color.white.opacity(0.3)) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.ringColor = ringColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(CGFloat(progress), 1.0))
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Graphic Rectangular Views

@available(watchOS 7.0, *)
struct GraphicRectangularStepsView: View {
    let data: ComplicationData
    let shoeImage: UIImage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -4.0) {
                HStack(alignment: .center) {
                    Image(uiImage: shoeImage.withRenderingMode(.alwaysTemplate))
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(ComplicationColors.blueTint)

                    Text(NSLocalizedString("Steps", comment: ""))
                        .font(.system(size: 17.0, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(ComplicationColors.blueTint)
                }
                
                Text(data.formattedSteps)
                    .font(.system(size: 42.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundColor(Color.white)
                    .complicationForeground()
            }
            
            Spacer()
        }
    }
}

@available(watchOS 7.0, *)
struct GraphicRectangularGaugeView: View {
    let data: ComplicationData
    let shoeImage: UIImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 4) {
                Image(uiImage: shoeImage.withRenderingMode(.alwaysTemplate))
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(ComplicationColors.blueTint)
                
                Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), data.formattedSteps))
                    .font(.system(size: 14.0, weight: .medium, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundColor(ComplicationColors.blueTint)
                
                Spacer()
            }
            
            if data.goalReached {
                Text(NSLocalizedString("Goal achieved!", comment: ""))
                    .font(.system(size: 12.0, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(data.trophy.symbol()) +\(StepsFormatter().formatSmall(data.stepsOver))")
                    .font(.system(size: 12.0, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            } else {
                Text(String(format: NSLocalizedString("%@ to go", comment: ""), StepsFormatter().formatSmall(data.stepsToGo)))
                    .font(.system(size: 12.0, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
                
                Gauge(value: Double(data.progress)) {
                    EmptyView()
                }
                .gaugeStyle(.linearCapacity)
                .tint(ComplicationColors.blueTint)
            }
        }
    }
}

// MARK: - Graphic Circular Views

@available(watchOS 7.0, *)
struct GraphicCircularStepsView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(spacing: -2) {
            Text(data.formattedSteps)
                .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
            
            Text(NSLocalizedString("steps", comment: ""))
                .font(.system(size: 10.0, weight: .regular, design: .rounded))
                .foregroundColor(ComplicationColors.blueTint)
        }
    }
}

@available(watchOS 7.0, *)
struct GraphicCircularGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        Gauge(value: Double(data.progress)) {
            Text(data.formattedStepsVeryShort)
                .font(.system(size: 14.0, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
        }
        .gaugeStyle(.circular)
        .tint(ComplicationColors.blueTint)
    }
}

// MARK: - Graphic Corner Views

@available(watchOS 7.0, *)
struct GraphicCornerStepsView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(data.formattedSteps)
                .font(.system(size: 20.0, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Text(NSLocalizedString("STEPS", comment: ""))
                .font(.system(size: 12.0, weight: .medium, design: .rounded))
                .foregroundColor(ComplicationColors.blueTint)
        }
    }
}

@available(watchOS 7.0, *)
struct GraphicCornerGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(data.formattedSteps)
                .font(.system(size: 20.0, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            if data.goalReached {
                Text(NSLocalizedString("Goal achieved!", comment: ""))
                    .font(.system(size: 10.0, weight: .regular, design: .rounded))
                    .foregroundColor(.green)
            } else {
                Text(data.formattedGoal)
                    .font(.system(size: 10.0, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Graphic Extra Large View

@available(watchOS 7.0, *)
struct GraphicExtraLargeView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                ProgressRingView(progress: Double(data.progress), lineWidth: 6.0)
                    .frame(width: 80, height: 80)
            }
            
            Text(data.formattedSteps)
                .font(.system(size: 24.0, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Accessory Views (watchOS 9+ / WidgetKit)

@available(watchOS 9.0, *)
struct AccessoryCircularStepsView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(spacing: -2) {
            Text(data.formattedStepsShort)
                .font(.system(size: 18.0, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
            
            Text(NSLocalizedString("steps", comment: ""))
                .font(.system(size: 9.0, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .widgetAccentable()
    }
}

@available(watchOS 9.0, *)
struct AccessoryCircularGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        Gauge(value: Double(data.progress)) {
            Text(data.formattedStepsVeryShort)
                .font(.system(size: 14.0, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .widgetAccentable()
    }
}

@available(watchOS 9.0, *)
struct AccessoryRectangularStepsView: View {
    let data: ComplicationData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(NSLocalizedString("Steps", comment: ""))
                    .font(.system(size: 12.0, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(data.formattedSteps)
                    .font(.system(size: 28.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .widgetAccentable()
            }
            Spacer()
        }
    }
}

@available(watchOS 9.0, *)
struct AccessoryRectangularGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), data.formattedSteps))
                    .font(.system(size: 12.0, weight: .medium, design: .rounded))
                    .widgetAccentable()
                Spacer()
            }
            
            if data.goalReached {
                Text(NSLocalizedString("Goal achieved!", comment: ""))
                    .font(.system(size: 11.0, weight: .regular, design: .rounded))
                
                Text("\(data.trophy.symbol()) +\(StepsFormatter().formatSmall(data.stepsOver))")
                    .font(.system(size: 11.0, weight: .regular, design: .rounded))
            } else {
                Text(String(format: NSLocalizedString("%@ to go", comment: ""), StepsFormatter().formatSmall(data.stepsToGo)))
                    .font(.system(size: 11.0, weight: .regular, design: .rounded))
                
                Gauge(value: Double(data.progress)) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
        }
    }
}

@available(watchOS 9.0, *)
struct AccessoryCornerStepsView: View {
    let data: ComplicationData
    
    var body: some View {
        Text(data.formattedStepsShort)
            .font(.system(size: 20.0, weight: .semibold, design: .rounded))
            .widgetAccentable()
            .widgetLabel {
                Text(NSLocalizedString("steps", comment: ""))
            }
    }
}

@available(watchOS 9.0, *)
struct AccessoryCornerGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        Text(data.formattedStepsShort)
            .font(.system(size: 20.0, weight: .semibold, design: .rounded))
            .widgetAccentable()
            .widgetLabel {
                Gauge(value: Double(data.progress)) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text(data.formattedGoal)
                }
                .gaugeStyle(.accessoryLinear)
            }
    }
}

@available(watchOS 9.0, *)
struct AccessoryInlineView: View {
    let data: ComplicationData
    
    var body: some View {
        Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), data.formattedSteps))
    }
}

// MARK: - Preview Providers

@available(watchOS 7.0, *)
struct ComplicationViews_Previews: PreviewProvider {
    static var sampleData: ComplicationData {
        ComplicationData(steps: 7890, goal: 10000, formatter: StepsFormatter())
    }
    
    static var goalReachedData: ComplicationData {
        ComplicationData(steps: 12500, goal: 10000, formatter: StepsFormatter())
    }
    
    static var previews: some View {
        Group {
            GraphicCircularStepsView(data: sampleData)
                .previewDisplayName("Circular Steps")
            
            GraphicCircularGaugeView(data: sampleData)
                .previewDisplayName("Circular Gauge")
            
            GraphicCornerStepsView(data: sampleData)
                .previewDisplayName("Corner Steps")
            
            GraphicExtraLargeView(data: sampleData)
                .previewDisplayName("Extra Large")
        }
    }
}
