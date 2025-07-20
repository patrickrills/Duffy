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
        
        var entrySteps: Steps = 0
        let entryDate: Date = Date()
        
        if !HealthCache.cacheIsForADifferentDay(than: entryDate) {
            entrySteps = HealthCache.lastSteps(for: entryDate)
        }
        
        entries.append(StepCountEntry(date: entryDate, steps: entrySteps))
        
        let tomorrow = entryDate.nextDay()
        if let oneSecondAfterMidnight = tomorrow.changeTime(hour: 0, minute: 0, second: 1) {
            entries.append(StepCountEntry(date: oneSecondAfterMidnight, steps: 0))
        }

//        let policy: TimelineReloadPolicy = entryDate.dateByAdding(.day, days: 1) < Date() ? .previousDay : .atEndOfMinute
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
