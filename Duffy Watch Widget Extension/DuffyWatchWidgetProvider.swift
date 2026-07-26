//
//  DuffyWatchWidgetProvider.swift
//  Duffy
//
//  Created by Patrick Rills on 7/26/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import WidgetKit
import DuffyWatchFramework

struct DuffyWatchWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DuffyWatchWidgetEntry {
        DuffyWatchWidgetEntry(date: Date(), steps: ComplicationDisplayModel.sampleSteps, goal: ComplicationDisplayModel.sampleGoal)
    }

    func getSnapshot(in context: Context, completion: @escaping (DuffyWatchWidgetEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DuffyWatchWidgetEntry>) -> Void) {
        let now = Date()
        var entries = [entry(for: now)]

        if let nextMidnight = Calendar.current.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 1), matchingPolicy: .nextTime) {
            entries.append(DuffyWatchWidgetEntry(date: nextMidnight, steps: 0, goal: HealthCache.dailyGoal()))
            completion(Timeline(entries: entries, policy: .after(nextMidnight)))
        } else {
            completion(Timeline(entries: entries, policy: .never))
        }
    }

    private func entry(for date: Date) -> DuffyWatchWidgetEntry {
        let steps: Steps = HealthCache.cacheIsForADifferentDay(than: date) ? 0 : HealthCache.lastSteps(for: date)
        return DuffyWatchWidgetEntry(date: date, steps: steps, goal: HealthCache.dailyGoal())
    }
}
