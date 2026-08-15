import SwiftUI
import WidgetKit
import DuffyWatchFramework

struct DuffyWatchWidget: Widget {
    let kind = WatchWidgetIdentifiers.stepsKind

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

// MARK: - Views

struct DuffyWatchWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DuffyWatchWidgetEntry

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

                Text(NSLocalizedString("steps", comment: ""))
                    .font(.system(.caption2, design: .rounded))
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                    .widgetAccentable()
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
                        .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                        .widgetAccentable()
                }
        } else {
            stepsText
                .widgetLabel {
                    Text(NSLocalizedString("STEPS", comment: ""))
                        .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                }
        }
    }

    private var inlineStepsView: some View {
        Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), ComplicationDisplayModel.formatStepsForLarge(entry.steps)))
            .minimumScaleFactor(0.6)
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
                        .foregroundStyle(Color(complicationColor: ComplicationDisplayModel.blueTint))
                        .widgetAccentable()

                    Text(NSLocalizedString("Steps", comment: ""))
                        .font(.system(size: 18.0, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                        .widgetAccentable()
                }

                Text(ComplicationDisplayModel.formatStepsForLarge(entry.steps))
                    .font(.system(size: 42.0, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }
}

struct DuffyWatchWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let sample: DuffyWatchWidgetEntry = DuffyWatchWidgetEntry(date: Date(), steps: 8000, goal: 10000)
        let family: WidgetFamily = .accessoryCircular
        let locale = "ja_JP"
        
        if #available(watchOS 10.0, *) {
            DuffyWatchWidgetEntryView(entry: sample)
                .previewContext(WidgetPreviewContext(family: family))
                .containerBackground(.background, for: .widget)
                .environment(\.locale, Locale(identifier: locale))
        } else {
            DuffyWatchWidgetEntryView(entry: sample)
                .previewContext(WidgetPreviewContext(family: family))
        }
    }
}
