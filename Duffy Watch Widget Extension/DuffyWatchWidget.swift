import SwiftUI
import WidgetKit

struct DuffyWatchWidgetEntry: TimelineEntry {
    let date: Date
}

struct DuffyWatchWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DuffyWatchWidgetEntry {
        DuffyWatchWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DuffyWatchWidgetEntry) -> Void) {
        completion(DuffyWatchWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DuffyWatchWidgetEntry>) -> Void) {
        completion(Timeline(entries: [DuffyWatchWidgetEntry(date: Date())], policy: .never))
    }
}

struct DuffyWatchWidgetEntryView: View {
    let entry: DuffyWatchWidgetEntry

    var body: some View {
        Text("Duffy")
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
