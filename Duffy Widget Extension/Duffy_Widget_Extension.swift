//
//  Duffy_Widget_Extension.swift
//  Duffy Widget Extension
//
//  Created by Patrick Rills on 7/13/25.
//  Copyright © 2025 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI
import DuffyFramework

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, steps: 5000)
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
            let entry = SimpleEntry(date: entryDate, steps: 1111) //HealthCache.lastSteps(for: Date())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let steps: Steps
}

struct Duffy_Widget_ExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack {
                Text("Time:")
                Text(entry.date, style: .time)
            }

            Text("Steps:")
            Text(entry.steps.formatted())
        }
    }
}

struct Duffy_Widget_Extension: Widget {
    let kind: String = "Duffy_Widget_Extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Duffy_Widget_ExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Duffy_Widget_ExtensionEntryView(entry: entry)
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
    Duffy_Widget_Extension()
} timeline: {
    SimpleEntry(date: .now, steps: 5000)
}
