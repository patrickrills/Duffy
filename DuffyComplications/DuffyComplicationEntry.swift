import WidgetKit
import Foundation
import DuffyWatchFramework

struct DuffyComplicationEntry: TimelineEntry {
    let date: Date
    let steps: Steps
    let goal: Steps
    let isGoalReached: Bool
    let complicationIdentifier: String
    
    init(date: Date, steps: Steps, goal: Steps, complicationIdentifier: String = "IDENTIFIER_JUST_STEPS") {
        self.date = date
        self.steps = steps
        self.goal = goal
        self.isGoalReached = steps >= goal
        self.complicationIdentifier = complicationIdentifier
    }
}
