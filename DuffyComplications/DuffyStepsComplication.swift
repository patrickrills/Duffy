import WidgetKit
import SwiftUI

struct DuffyStepsComplication: Widget {
    let kind: String = "com.bigbluefly.duffy.steps-complication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyComplicationProvider()) { entry in
            DuffyComplicationView(entry: entry)
        }
        .configurationDisplayName("Duffy Steps")
        .description("Shows your current step count and progress toward your daily goal.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
