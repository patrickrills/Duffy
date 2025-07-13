//
//  StepCountWidget.swift
//  Duffy
//
//  Created by Patrick Rills on 7/13/25.
//  Copyright © 2025 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI

struct LockScreenStepCountWidget: Widget {
    let kind: String = "com.bigbluefly.duffy.lock-step-count-widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenStepCountWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Step Count")
        .description("Displays your current step count.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    LockScreenStepCountWidget()
} timeline: {
    StepCountEntry(date: .now, steps: 5000)
}
