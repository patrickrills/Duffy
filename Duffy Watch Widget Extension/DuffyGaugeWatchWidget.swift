//
//  DuffyGaugeWatchWidget.swift
//  Duffy
//
//  Created by Patrick Rills on 7/26/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI
import DuffyWatchFramework

struct DuffyGaugeWatchWidget: Widget {
    let kind = WatchWidgetIdentifiers.gaugeKind

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

// MARK: - Views

struct DuffyGaugeWatchWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DuffyWatchWidgetEntry

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
        Gauge(value: Double(ComplicationDisplayModel.gaugeFillFraction(totalSteps: entry.steps, goal: entry.goal))) {
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
        .tint(Color(complicationColor: ComplicationDisplayModel.blueTint))
        .widgetAccentable()
    }

    @ViewBuilder
    private var cornerGaugeView: some View {
        if ComplicationDisplayModel.goalReached(totalSteps: entry.steps, goal: entry.goal) {
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
                    ProgressView(value: Double(ComplicationDisplayModel.gaugeFillFraction(totalSteps: entry.steps, goal: entry.goal)))
                        .tint(Color(complicationColor: ComplicationDisplayModel.blueTint))
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
            HStack(alignment: .center, spacing: 6.0) {
                Image("GraphicRectShoe")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14.0, height: 14.0)
                    .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                    .widgetAccentable()

                Text(String(format: NSLocalizedString("%@ STEPS", comment: ""), ComplicationDisplayModel.formatStepsForLarge(entry.steps)))
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 4.0) {
                if ComplicationDisplayModel.goalReached(totalSteps: entry.steps, goal: entry.goal) {
                    Text(NSLocalizedString("Goal achieved!", comment: ""))
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .lineLimit(1)
                        .foregroundColor(Color(complicationColor: ComplicationDisplayModel.blueTint))
                        .widgetAccentable()

                    Text(ComplicationDisplayModel.graphicRectangularProgressText(totalSteps: entry.steps, goal: entry.goal))
                        .font(.system(.callout, design: .rounded, weight: .regular))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                } else {
                    Text(ComplicationDisplayModel.graphicRectangularProgressText(totalSteps: entry.steps, goal: entry.goal))
                        .font(.system(.callout, design: .rounded, weight: .regular))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)

                    Gauge(value: Double(ComplicationDisplayModel.gaugeFillFraction(totalSteps: entry.steps, goal: entry.goal))) {
                        EmptyView()
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(Color(complicationColor: ComplicationDisplayModel.blueTint))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DuffyGaugeWatchWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let sample: DuffyWatchWidgetEntry = DuffyWatchWidgetEntry(date: Date(), steps: 8000, goal: 10000)
        let family: WidgetFamily = .accessoryRectangular
        let locale = "ja_JP"
        
        if #available(watchOS 10.0, *) {
            DuffyGaugeWatchWidgetEntryView(entry: sample)
                .previewContext(WidgetPreviewContext(family: family))
                .containerBackground(.background, for: .widget)
                .environment(\.locale, Locale(identifier: locale))
        } else {
            DuffyGaugeWatchWidgetEntryView(entry: sample)
                .previewContext(WidgetPreviewContext(family: family))
        }
    }
}
