import SwiftUI
import WidgetKit
import DuffyWatchFramework

struct DuffyWatchWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Steps
    let goal: Steps
}

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

struct DuffyWatchWidgetEntryView: View {
    let entry: DuffyWatchWidgetEntry

    var body: some View {
        Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
    }
}

struct DuffyWatchWidget: Widget {
    let kind = "com.bigbluefly.Duffy.watch.placeholder"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWatchWidgetProvider()) { entry in
            DuffyWatchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Duffy")
        .description("Shows your steps.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

@main
struct DuffyWatchWidgets: WidgetBundle {
    var body: some Widget {
        DuffyWatchWidget()
    }
}
