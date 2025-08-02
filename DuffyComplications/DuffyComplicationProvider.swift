import WidgetKit
import SwiftUI
import DuffyWatchFramework

struct DuffyComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> DuffyComplicationEntry {
        DuffyComplicationEntry(
            date: Date(),
            steps: 8500,
            goal: 10000,
            complicationIdentifier: "IDENTIFIER_JUST_STEPS"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DuffyComplicationEntry) -> Void) {
        let entry = DuffyComplicationEntry(
            date: Date(),
            steps: 8500,
            goal: 10000,
            complicationIdentifier: "IDENTIFIER_JUST_STEPS"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DuffyComplicationEntry>) -> Void) {
        let currentDate = Date()
        let currentSteps = HealthCache.lastSteps(for: currentDate)
        let currentGoal = HealthCache.dailyGoal()
        
        let entry = DuffyComplicationEntry(
            date: currentDate,
            steps: currentSteps,
            goal: currentGoal,
            complicationIdentifier: "IDENTIFIER_JUST_STEPS"
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
