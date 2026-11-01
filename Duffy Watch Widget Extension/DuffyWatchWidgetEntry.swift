//
//  DuffyWatchWidgetEntry.swift
//  Duffy
//
//  Created by Patrick Rills on 7/26/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import WidgetKit
import DuffyWatchFramework

struct DuffyWatchWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Steps
    let goal: Steps

    var relevance: TimelineEntryRelevance? {
        let progress = ComplicationDisplayModel.gaugeFillFraction(totalSteps: steps, goal: goal)
        guard progress > 0 else {
            return TimelineEntryRelevance(score: 0)
        }

        let score: Float = ComplicationDisplayModel.goalReached(totalSteps: steps, goal: goal)
            ? 20.0
            : max(1.0, progress * 10.0)
        return TimelineEntryRelevance(score: score, duration: secondsUntilNextDay)
    }

    private var secondsUntilNextDay: TimeInterval {
        guard let nextDay = Calendar.current.nextDate(after: date, matching: DateComponents(hour: 0, minute: 0, second: 1), matchingPolicy: .nextTime) else {
            return 0
        }

        return nextDay.timeIntervalSince(date)
    }
}
