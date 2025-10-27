import WidgetKit
import SwiftUI
import DuffyWatchFramework

struct DuffyComplicationView: View {
    var entry: DuffyComplicationEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryInline:
            DuffyInlineComplicationView(entry: entry)
        case .accessoryCircular:
            DuffyCircularComplicationView(entry: entry)
        case .accessoryRectangular:
            DuffyRectangularComplicationView(entry: entry)
        case .accessoryCorner:
            DuffyCornerComplicationView(entry: entry)
        default:
            Text("Unsupported")
        }
    }
}

struct DuffyInlineComplicationView: View {
    var entry: DuffyComplicationEntry
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "figure.walk")
            Text(formatStepsForVerySmall(entry.steps))
        }
        .privacySensitive()
    }
}

struct DuffyCircularComplicationView: View {
    var entry: DuffyComplicationEntry
    
    var body: some View {
        ZStack {
            if entry.complicationIdentifier.contains("GAUGE") {
                Gauge(value: Double(entry.steps), in: 0...Double(entry.goal)) {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                } currentValueLabel: {
                    Text(formatStepsForVerySmall(entry.steps))
                        .font(.caption2)
                }
                .gaugeStyle(.accessoryCircular)
            } else {
                VStack(spacing: 1) {
                    Image(systemName: "figure.walk")
                        .font(.caption)
                    Text(formatStepsForVerySmall(entry.steps))
                        .font(.caption2)
                        .fontWeight(.medium)
                }
            }
        }
        .privacySensitive()
    }
}

struct DuffyRectangularComplicationView: View {
    var entry: DuffyComplicationEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk")
                        .font(.caption)
                    Text("Steps")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                Text(formatStepsForLarge(entry.steps))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            if entry.complicationIdentifier.contains("GAUGE") {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatStepsForLarge(entry.goal))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .privacySensitive()
    }
}

struct DuffyCornerComplicationView: View {
    var entry: DuffyComplicationEntry
    
    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "figure.walk")
                .font(.caption)
            Text(formatStepsForVerySmall(entry.steps))
                .font(.caption2)
                .fontWeight(.medium)
        }
        .privacySensitive()
    }
}

private func formatStepsForLarge(_ totalSteps: Steps) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.locale = Locale.current
    if let format = numberFormatter.string(for: totalSteps) {
        return format
    }
    
    return "0"
}

private func formatStepsForSmall(_ totalSteps: Steps) -> String {
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

private func formatStepsForVerySmall(_ totalSteps: Steps) -> String {
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
