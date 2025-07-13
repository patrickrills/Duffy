//
//  Provider.swift
//  Duffy
//
//  Created by Patrick Rills on 7/13/25.
//  Copyright © 2025 Big Blue Fly. All rights reserved.
//

import WidgetKit
import DuffyFramework

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StepCountEntry {
        StepCountEntry(date: .now, steps: 5000)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepCountEntry) -> ()) {
        let entry = StepCountEntry(date: Date(), steps: HealthCache.lastSteps(for: Date()))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [StepCountEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StepCountEntry(date: entryDate, steps: 1111) //HealthCache.lastSteps(for: Date())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
