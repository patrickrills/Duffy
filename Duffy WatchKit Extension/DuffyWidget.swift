//
//  DuffyWidget.swift
//  Duffy WatchKit Extension
//
//  Created by Devin AI on 12/1/24.
//  Copyright © 2024 Big Blue Fly. All rights reserved.
//

import SwiftUI
import ClockKit
import DuffyWatchFramework

#if canImport(WidgetKit)
import WidgetKit

// MARK: - Widget Entry

@available(watchOS 9.0, *)
struct DuffyWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Steps
    let goal: Steps
    
    var complicationData: ComplicationData {
        ComplicationData(steps: steps, goal: goal, formatter: StepsFormatter())
    }
    
    static var placeholder: DuffyWidgetEntry {
        DuffyWidgetEntry(date: Date(), steps: 5000, goal: 10000)
    }
}

// MARK: - Timeline Provider

@available(watchOS 9.0, *)
struct DuffyWidgetProvider: TimelineProvider {
    typealias Entry = DuffyWidgetEntry
    
    func placeholder(in context: Context) -> DuffyWidgetEntry {
        DuffyWidgetEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DuffyWidgetEntry) -> Void) {
        let steps = getCurrentSteps()
        let goal = HealthCache.dailyGoal()
        completion(DuffyWidgetEntry(date: Date(), steps: steps, goal: goal))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DuffyWidgetEntry>) -> Void) {
        let steps = getCurrentSteps()
        let goal = HealthCache.dailyGoal()
        let entry = DuffyWidgetEntry(date: Date(), steps: steps, goal: goal)
        
        // Create a timeline entry for tomorrow at midnight to reset the steps
        let tomorrow = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let tomorrowEntry = DuffyWidgetEntry(date: tomorrow, steps: 0, goal: goal)
        
        // Refresh policy: after tomorrow's entry date
        let timeline = Timeline(entries: [entry, tomorrowEntry], policy: .after(tomorrow))
        completion(timeline)
    }
    
    private func getCurrentSteps() -> Steps {
        if !HealthCache.cacheIsForADifferentDay(than: Date()) {
            return HealthCache.lastSteps(for: Date())
        }
        return 0
    }
}

// MARK: - Widget Entry Views

@available(watchOS 9.0, *)
struct DuffyWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DuffyWidgetEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularStepsView(data: entry.complicationData)
        case .accessoryRectangular:
            AccessoryRectangularStepsView(data: entry.complicationData)
        case .accessoryCorner:
            AccessoryCornerStepsView(data: entry.complicationData)
        case .accessoryInline:
            AccessoryInlineView(data: entry.complicationData)
        default:
            Text("\(entry.steps)")
        }
    }
}

@available(watchOS 9.0, *)
struct DuffyGaugeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DuffyWidgetEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularGaugeView(data: entry.complicationData)
        case .accessoryRectangular:
            AccessoryRectangularGaugeView(data: entry.complicationData)
        case .accessoryCorner:
            AccessoryCornerGaugeView(data: entry.complicationData)
        case .accessoryInline:
            AccessoryInlineView(data: entry.complicationData)
        default:
            Text("\(entry.steps)")
        }
    }
}

// MARK: - Widget Definitions

@available(watchOS 9.0, *)
struct DuffyWidget: Widget {
    let kind: String = "DuffyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWidgetProvider()) { entry in
            DuffyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Duffy")
        .description(NSLocalizedString("Track your daily steps", comment: ""))
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

@available(watchOS 9.0, *)
struct DuffyGaugeWidget: Widget {
    let kind: String = "DuffyGaugeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWidgetProvider()) { entry in
            DuffyGaugeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Duffy (Gauge)")
        .description(NSLocalizedString("Track your daily steps with progress", comment: ""))
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner
        ])
    }
}

// MARK: - Widget Bundle

@available(watchOS 9.0, *)
struct DuffyWidgetBundle: WidgetBundle {
    var body: some Widget {
        DuffyWidget()
        DuffyGaugeWidget()
    }
}

// MARK: - Preview Provider

@available(watchOS 9.0, *)
struct DuffyWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DuffyWidgetEntryView(entry: DuffyWidgetEntry(date: Date(), steps: 7890, goal: 10000))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            DuffyWidgetEntryView(entry: DuffyWidgetEntry(date: Date(), steps: 7890, goal: 10000))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            DuffyGaugeWidgetEntryView(entry: DuffyWidgetEntry(date: Date(), steps: 7890, goal: 10000))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular Gauge")
            
            DuffyGaugeWidgetEntryView(entry: DuffyWidgetEntry(date: Date(), steps: 12500, goal: 10000))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular Gauge - Goal Reached")
        }
    }
}

#endif
