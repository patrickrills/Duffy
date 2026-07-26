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
                    .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
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
                        .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
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
                    .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                    .widgetAccentable()
            }

            Spacer(minLength: 0)
        }
    }
}
