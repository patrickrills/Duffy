//
//  DuffyWidget.swift
//  Duffy
//
//  Created with WidgetKit for iOS 17+.
//

import WidgetKit
import SwiftUI

private let sharedGroupName = "group.com.bigbluefly.Duffy"

struct StepEntry: TimelineEntry {
    let date: Date
    let steps: UInt
}

struct StepCountProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepEntry {
        StepEntry(date: Date(), steps: 10000)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepEntry) -> Void) {
        completion(StepEntry(date: Date(), steps: readStepsFromCache()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepEntry>) -> Void) {
        let entry = StepEntry(date: Date(), steps: readStepsFromCache())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readStepsFromCache() -> UInt {
        guard let sharedDefaults = UserDefaults(suiteName: sharedGroupName),
              let stepsDict = sharedDefaults.object(forKey: "stepsCache") as? [String: Any],
              let cachedSteps = stepsDict["stepsCacheValue"] as? UInt,
              let cachedDay = stepsDict["stepsCacheDay"] as? String
        else {
            return 0
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        guard cachedDay == formatter.string(from: Date()) else {
            return 0
        }

        return cachedSteps
    }
}

struct DuffyWidgetEntryView: View {
    var entry: StepEntry

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "figure.walk")
                .font(.title2)
                .foregroundStyle(.blue)
            Text(formattedSteps)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .minimumScaleFactor(0.5)
            Text("steps")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: entry.steps)) ?? "\(entry.steps)"
    }
}

@main
struct DuffyWidget: Widget {
    let kind: String = "DuffyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepCountProvider()) { entry in
            DuffyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Step Count")
        .description("See your step count at a glance.")
        .supportedFamilies([.systemSmall])
    }
}
