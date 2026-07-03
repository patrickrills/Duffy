import SwiftUI
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
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: -1) {
                Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(blueTint)
                    .widgetAccentable()

                Text(NSLocalizedString("steps", comment: ""))
                    .font(.system(.caption2, design: .rounded))
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
            }
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
                HStack(alignment: .center, spacing: 8.0) {
                    Image("GraphicRectShoe")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16.0, height: 16.0)

                    Text(NSLocalizedString("Steps", comment: ""))
                        .font(.system(size: 17.0, weight: .regular, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }

                Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                    .font(.system(size: 42.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundColor(blueTint)
                    .widgetAccentable()
            }

            Spacer(minLength: 0)
        }
    }
}

struct DuffyGaugeWatchWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DuffyWatchWidgetEntry

    private var blueTint: Color {
        Color(complicationColor: ComplicationDisplayModel.blueTint)
    }

    private var fillFraction: Double {
        Double(ComplicationDisplayModel.gaugeFillFraction(totalSteps: entry.steps, goal: entry.goal))
    }

    private var goalReached: Bool {
        ComplicationDisplayModel.goalReached(totalSteps: entry.steps, goal: entry.goal)
    }

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            circularGaugeView
        case .accessoryCorner:
            cornerGaugeView
        case .accessoryRectangular:
            rectangularGaugeView
        default:
            rectangularGaugeView
        }
    }

    private var circularGaugeView: some View {
        Gauge(value: fillFraction) {
            Text(NSLocalizedString("Steps", comment: ""))
        } currentValueLabel: {
            VStack(spacing: 2.0) {
                Image("GraphicRectShoe")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 8.0, height: 8.0)
                Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.5)
            }
            
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(blueTint)
        .widgetAccentable()
    }

    @ViewBuilder
    private var cornerGaugeView: some View {
        if goalReached {
            let goalText = Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                .font(.system(.body, design: .rounded, weight: .semibold))
                .minimumScaleFactor(0.6)
                .widgetLabel {
                    Text(NSLocalizedString("Goal achieved!", comment: ""))
                }
            
            if #available(watchOS 10.0, *) {
                goalText
                    .widgetCurvesContent()
            } else {
                goalText
            }
        } else {
            let cornerGauge = Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                .font(.system(.body, design: .rounded, weight: .semibold))
                .minimumScaleFactor(0.6)
                .widgetLabel {
                    ProgressView(value: fillFraction)
                }
            
            if #available(watchOS 10.0, *) {
                cornerGauge
                    .widgetCurvesContent()
            } else {
                cornerGauge
            }
        }
    }

    private var rectangularGaugeView: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            HStack(alignment: .center, spacing: 8.0) {
                Image("GraphicRectShoe")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14.0, height: 14.0)
                    .foregroundColor(blueTint)
                    .widgetAccentable()

                Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), ComplicationDisplayModel.formatStepsForLarge(entry.steps)))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(blueTint)
                    .widgetAccentable()
            }

            VStack(alignment: .leading, spacing: 4.0) {
                if goalReached {
                    Text(NSLocalizedString("Goal achieved!", comment: ""))
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .lineLimit(1)

                    Text(ComplicationDisplayModel.graphicRectangularProgressText(totalSteps: entry.steps, goal: entry.goal))
                        .font(.system(.callout, design: .rounded, weight: .regular))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                } else {
                    Text(ComplicationDisplayModel.graphicRectangularProgressText(totalSteps: entry.steps, goal: entry.goal))
                        .font(.system(.callout, design: .rounded, weight: .regular))
                        .lineLimit(1)

                    Gauge(value: fillFraction) {
                        EmptyView()
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(blueTint)
                }
            }
        }
    }
}

struct DuffyWatchWidget: Widget {
    let kind = "com.bigbluefly.Duffy.watch.placeholder"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWatchWidgetProvider()) { entry in
            if #available(watchOS 10.0, *) {
                DuffyWatchWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                DuffyWatchWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Duffy")
        .description("Shows your steps.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

struct DuffyGaugeWatchWidget: Widget {
    let kind = "com.bigbluefly.Duffy.watch.gauge"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWatchWidgetProvider()) { entry in
            if #available(watchOS 10.0, *) {
                DuffyGaugeWatchWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                DuffyGaugeWatchWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Duffy (Gauge)")
        .description("Shows your progress toward your step goal.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular])
    }
}

@main
struct DuffyWatchWidgets: WidgetBundle {
    var body: some Widget {
        DuffyWatchWidget()
        DuffyGaugeWatchWidget()
    }
}

private extension Color {
    init(complicationColor color: ComplicationColorComponents) {
        self.init(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}
