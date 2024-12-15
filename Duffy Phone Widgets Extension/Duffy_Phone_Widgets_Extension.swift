//
//  Duffy_Phone_Widgets_Extension.swift
//  Duffy Phone Widgets Extension
//
//  Created by Patrick Rills on 12/15/24.
//  Copyright © 2024 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI
import DuffyFramework

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), steps: HealthCache.lastSteps(for: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), steps: HealthCache.lastSteps(for: Date()))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, steps: HealthCache.lastSteps(for: Date()))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let steps: Steps
}

struct Duffy_Phone_Widgets_ExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Steps:")
            Text(entry.steps.formatted())
        }
    }
}

struct Duffy_Phone_Widgets_Extension: Widget {
    let kind: String = "Duffy_Phone_Widgets_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Duffy_Phone_Widgets_ExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Duffy_Phone_Widgets_ExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    Duffy_Phone_Widgets_Extension()
} timeline: {
    SimpleEntry(date: .now, steps: HealthCache.lastSteps(for: Date()))
}
