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
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DuffyWatchWidgetEntry

    private var blueTint: Color {
        Color(complicationColor: ComplicationDisplayModel.blueTint)
    }

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            circularStepsView
        case .accessoryCorner:
            cornerStepsView
        case .accessoryInline:
            inlineStepsView
        case .accessoryRectangular:
            rectangularStepsView
        default:
            rectangularStepsView
        }
    }

    private var circularStepsView: some View {
        VStack(spacing: -1) {
            Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps, useGroupingSeparator: entry.steps <= 10000))
                .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.45)
                .lineLimit(1)

            Text(NSLocalizedString("steps", comment: ""))
                .font(.system(size: 10.0, weight: .medium, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundColor(blueTint)
        }
    }

    @ViewBuilder
    private var cornerStepsView: some View {
        let stepsText = Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
            .font(.system(.body, design: .rounded, weight: .semibold))
            .minimumScaleFactor(0.6)

        if #available(watchOSApplicationExtension 10.0, *) {
            stepsText
                .widgetCurvesContent()
                .widgetLabel {
                    Text(NSLocalizedString("STEPS", comment: ""))
                        .foregroundColor(blueTint)
                }
        } else {
            stepsText
                .widgetLabel {
                    Text(NSLocalizedString("STEPS", comment: ""))
                        .foregroundColor(blueTint)
                }
        }
    }

    private var inlineStepsView: some View {
        Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), ComplicationDisplayModel.formatStepsForLarge(entry.steps)))
    }

    private var rectangularStepsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: -4.0) {
                HStack(alignment: .center, spacing: 3.0) {
                    Image("GraphicRectShoe")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16.0, height: 16.0)
                        .foregroundColor(blueTint)

                    Text(NSLocalizedString("Steps", comment: ""))
                        .font(.system(size: 17.0, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(blueTint)
                }

                Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                    .font(.system(size: 42.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }

            Spacer(minLength: 0)
        }
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

private extension Color {
    init(complicationColor color: ComplicationColorComponents) {
        self.init(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}
