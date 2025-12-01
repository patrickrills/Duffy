# Duffy Complications Migration Plan: ClockKit to SwiftUI

## Executive Summary

This document outlines a plan to convert Apple Watch complications in Duffy from ClockKit to SwiftUI while maintaining backward compatibility with watchOS 5.0. The migration will use a phased approach with conditional compilation to support both legacy ClockKit (watchOS 5.0-8.x) and modern WidgetKit (watchOS 9.0+) implementations.

## Current State Analysis

### Deployment Target
- Current watchOS deployment target: **5.0**
- Swift version: **5.0**

### Existing Complication Implementation

The current implementation in `ComplicationController.swift` supports 11 complication families across two identifiers:

**Complication Identifiers:**
1. `Duffy-Steps` ("Just Steps") - Shows step count only
2. `Duffy-Gauges` - Shows step count with progress gauge toward goal

**Supported Complication Families:**

| Family | watchOS Version | Current Template |
|--------|-----------------|------------------|
| `modularSmall` | 2.0+ | `CLKComplicationTemplateModularSmallStackText` |
| `modularLarge` | 2.0+ | `CLKComplicationTemplateModularLargeTallBody` |
| `circularSmall` | 2.0+ | `CLKComplicationTemplateCircularSmallStackText` |
| `utilitarianLarge` | 2.0+ | `CLKComplicationTemplateUtilitarianLargeFlat` |
| `utilitarianSmall` | 2.0+ | `CLKComplicationTemplateUtilitarianSmallFlat` |
| `utilitarianSmallFlat` | 2.0+ | `CLKComplicationTemplateUtilitarianSmallFlat` |
| `extraLarge` | 3.0+ | `CLKComplicationTemplateExtraLargeStackImage` |
| `graphicCorner` | 5.0+ | `CLKComplicationTemplateGraphicCornerGaugeText` / `StackText` |
| `graphicCircular` | 5.0+ | `CLKComplicationTemplateGraphicCircularClosedGaugeText` / `StackText` |
| `graphicBezel` | 5.0+ | `CLKComplicationTemplateGraphicBezelCircularText` |
| `graphicRectangular` | 5.0+ | `CLKComplicationTemplateGraphicRectangularTextGauge` / `FullView` |
| `graphicExtraLarge` | 7.0+ | `CLKComplicationTemplateGraphicExtraLargeCircularStackImage` |

### Existing SwiftUI Usage

The app already uses SwiftUI for one complication view:
- `GraphicRectangularFullView.swift` - Used with `CLKComplicationTemplateGraphicRectangularFullView` (watchOS 7.0+)

### Key Dependencies
- `RingDrawer` - Draws progress ring images using CoreGraphics
- `HealthCache` - Provides step count and goal data
- `Trophy` - Determines achievement level based on steps

---

## watchOS Complications API Timeline

Understanding the API availability is critical for backward compatibility:

| watchOS Version | API Availability |
|-----------------|------------------|
| 5.0 - 6.x | ClockKit only |
| 7.0 | ClockKit + SwiftUI templates (`CLKComplicationTemplate...FullView`) |
| 9.0+ | WidgetKit for complications (ClockKit deprecated) |

**Key Insight:** WidgetKit complications require watchOS 9.0 minimum. To support watchOS 5.0, you MUST maintain ClockKit code.

---

## Migration Strategy

### Recommended Approach: Hybrid Architecture

Given the requirement to support watchOS 5.0, the recommended approach is a **hybrid architecture** using conditional compilation:

```
watchOS 5.0 - 6.x  -->  ClockKit (legacy templates)
watchOS 7.0 - 8.x  -->  ClockKit with SwiftUI views (where possible)
watchOS 9.0+       -->  WidgetKit (modern SwiftUI widgets)
```

This approach:
1. Maintains full backward compatibility with watchOS 5.0
2. Provides improved SwiftUI-based rendering for watchOS 7.0+
3. Uses modern WidgetKit for watchOS 9.0+ users
4. Allows gradual deprecation of older watchOS versions in future releases

---

## Phase 1: Create Shared SwiftUI Complication Views

### Objective
Create reusable SwiftUI views that can be used by both ClockKit (watchOS 7+) and WidgetKit (watchOS 9+).

### Tasks

#### 1.1 Create a new file: `ComplicationViews.swift`

This file will contain all SwiftUI views for complications, organized by complication family.

```swift
// ComplicationViews.swift
import SwiftUI
import ClockKit

// MARK: - Shared Data Model

struct ComplicationData {
    let steps: UInt
    let goal: UInt
    let formattedSteps: String
    let formattedStepsShort: String
    let formattedGoal: String
    let progress: Float
    let goalReached: Bool
    let trophy: Trophy?
}

// MARK: - Color Constants

enum ComplicationColors {
    static let blueTint = Color(red: 32.0/255.0, green: 148.0/255.0, blue: 250.0/255.0)
    static let tealTint = Color(red: 45.0/255.0, green: 221.0/255.0, blue: 255.0/255.0)
}

// MARK: - Graphic Rectangular Views

@available(watchOS 7.0, *)
struct GraphicRectangularStepsView: View {
    let data: ComplicationData
    let showGauge: Bool
    
    var body: some View {
        // Implementation
    }
}

@available(watchOS 7.0, *)
struct GraphicRectangularGaugeView: View {
    let data: ComplicationData
    
    var body: some View {
        // Implementation with gauge
    }
}

// MARK: - Graphic Circular Views

@available(watchOS 7.0, *)
struct GraphicCircularStepsView: View {
    let data: ComplicationData
    let showGauge: Bool
    
    var body: some View {
        // Implementation
    }
}

// MARK: - Graphic Corner Views

@available(watchOS 7.0, *)
struct GraphicCornerStepsView: View {
    let data: ComplicationData
    let showGauge: Bool
    
    var body: some View {
        // Implementation
    }
}

// MARK: - Accessory Views (watchOS 9+ / WidgetKit)

@available(watchOS 9.0, *)
struct AccessoryCircularView: View {
    let data: ComplicationData
    
    var body: some View {
        // Implementation for accessoryCircular
    }
}

@available(watchOS 9.0, *)
struct AccessoryRectangularView: View {
    let data: ComplicationData
    
    var body: some View {
        // Implementation for accessoryRectangular
    }
}

@available(watchOS 9.0, *)
struct AccessoryCornerView: View {
    let data: ComplicationData
    
    var body: some View {
        // Implementation for accessoryCorner
    }
}

@available(watchOS 9.0, *)
struct AccessoryInlineView: View {
    let data: ComplicationData
    
    var body: some View {
        // Implementation for accessoryInline
    }
}
```

#### 1.2 Create SwiftUI-based Ring/Gauge View

Replace `RingDrawer` image generation with a SwiftUI `Gauge` or custom `Shape` for watchOS 7+:

```swift
@available(watchOS 7.0, *)
struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(Color.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
```

#### 1.3 Migrate `GraphicRectangularFullView`

The existing `GraphicRectangularFullView.swift` is already a good template. Refactor it to use the shared `ComplicationData` model.

---

## Phase 2: Update ClockKit Implementation for watchOS 7+

### Objective
Update `ComplicationController.swift` to use SwiftUI views via `CLKComplicationTemplate...FullView` templates where available (watchOS 7.0+).

### Tasks

#### 2.1 Update Graphic Rectangular Templates

```swift
@available(watchOS 7.0, *)
func getTemplateForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
    let data = createComplicationData(steps: totalSteps, goal: goal)
    return CLKComplicationTemplateGraphicRectangularFullView(
        GraphicRectangularGaugeView(data: data)
    )
}
```

#### 2.2 Update Graphic Circular Templates (watchOS 7+)

```swift
@available(watchOS 7.0, *)
func getTemplateForGraphicCircularSwiftUI(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
    let data = createComplicationData(steps: totalSteps, goal: goal)
    return CLKComplicationTemplateGraphicCircularView(
        GraphicCircularStepsView(data: data, showGauge: true)
    )
}
```

#### 2.3 Update Graphic Extra Large Templates (watchOS 7+)

```swift
@available(watchOS 7.0, *)
func getTemplateForGraphicExtraLargeSwiftUI(_ totalSteps: Steps) -> CLKComplicationTemplate {
    let data = createComplicationData(steps: totalSteps, goal: HealthCache.dailyGoal())
    return CLKComplicationTemplateGraphicExtraLargeCircularView(
        GraphicExtraLargeView(data: data)
    )
}
```

#### 2.4 Maintain Legacy Templates

Keep existing template methods for watchOS 5.0-6.x compatibility. Use `#available` checks:

```swift
func entry(for complication: CLKComplication, with steps: Steps) -> CLKComplicationTimelineEntry? {
    // ...
    case .graphicRectangular:
        if #available(watchOS 7.0, *) {
            return getEntryForGraphicRectangleSwiftUI(steps, stepsGoal)
        } else {
            return getEntryForGraphicRectangle(steps, stepsGoal)
        }
    // ...
}
```

---

## Phase 3: Add WidgetKit Implementation (watchOS 9+)

### Objective
Create a new WidgetKit-based complication implementation for watchOS 9.0+.

### Tasks

#### 3.1 Create Widget Extension Target (Optional)

For cleaner separation, consider creating a separate Widget Extension target. However, for simplicity, you can add WidgetKit code to the existing WatchKit Extension with conditional compilation.

#### 3.2 Create `DuffyWidget.swift`

```swift
import WidgetKit
import SwiftUI

@available(watchOS 9.0, *)
struct DuffyWidgetProvider: TimelineProvider {
    typealias Entry = DuffyWidgetEntry
    
    func placeholder(in context: Context) -> DuffyWidgetEntry {
        DuffyWidgetEntry(date: Date(), steps: 5000, goal: 10000)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DuffyWidgetEntry) -> Void) {
        let steps = HealthCache.lastSteps(for: Date())
        let goal = HealthCache.dailyGoal()
        completion(DuffyWidgetEntry(date: Date(), steps: steps, goal: goal))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DuffyWidgetEntry>) -> Void) {
        let steps = HealthCache.lastSteps(for: Date())
        let goal = HealthCache.dailyGoal()
        let entry = DuffyWidgetEntry(date: Date(), steps: steps, goal: goal)
        
        // Refresh at midnight
        let tomorrow = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

@available(watchOS 9.0, *)
struct DuffyWidgetEntry: TimelineEntry {
    let date: Date
    let steps: UInt
    let goal: UInt
    
    var complicationData: ComplicationData {
        // Create ComplicationData from entry
    }
}

@available(watchOS 9.0, *)
struct DuffyWidget: Widget {
    let kind: String = "DuffyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWidgetProvider()) { entry in
            DuffyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Duffy")
        .description("Track your daily steps")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

@available(watchOS 9.0, *)
struct DuffyWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DuffyWidgetEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            AccessoryCircularView(data: entry.complicationData)
        case .accessoryRectangular:
            AccessoryRectangularView(data: entry.complicationData)
        case .accessoryCorner:
            AccessoryCornerView(data: entry.complicationData)
        case .accessoryInline:
            AccessoryInlineView(data: entry.complicationData)
        default:
            Text("\(entry.steps)")
        }
    }
}
```

#### 3.3 Create Gauge Widget (Second Configuration)

```swift
@available(watchOS 9.0, *)
struct DuffyGaugeWidget: Widget {
    let kind: String = "DuffyGaugeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DuffyWidgetProvider()) { entry in
            DuffyGaugeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Duffy (Gauge)")
        .description("Track your daily steps with progress")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner
        ])
    }
}
```

#### 3.4 Register Widgets in Widget Bundle

```swift
@available(watchOS 9.0, *)
@main
struct DuffyWidgetBundle: WidgetBundle {
    var body: some Widget {
        DuffyWidget()
        DuffyGaugeWidget()
    }
}
```

#### 3.5 Update Info.plist

Add WidgetKit configuration to `Info.plist` for watchOS 9+.

---

## Phase 4: Update Complication Refresh Logic

### Objective
Ensure complications refresh correctly for both ClockKit and WidgetKit.

### Tasks

#### 4.1 Update `ComplicationController.refreshComplication()`

```swift
class func refreshComplication() {
    if #available(watchOS 9.0, *) {
        // Refresh WidgetKit complications
        WidgetCenter.shared.reloadTimelines(ofKind: "DuffyWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "DuffyGaugeWidget")
    }
    
    // Also refresh ClockKit for backward compatibility
    let server = CLKComplicationServer.sharedInstance()
    if let allComplications = server.activeComplications {
        allComplications.forEach { server.reloadTimeline(for: $0) }
    }
}
```

#### 4.2 Update Background Refresh Handling

In `ExtensionDelegate.swift`, ensure both systems are refreshed:

```swift
func complicationUpdateRequested() {
    ComplicationController.refreshComplication()
    scheduleSnapshotNow()
}
```

---

## Phase 5: Testing and Validation

### Test Matrix

| watchOS Version | Test Scenarios |
|-----------------|----------------|
| 5.0 | All ClockKit families render correctly |
| 6.0 | All ClockKit families render correctly |
| 7.0 | SwiftUI templates render correctly for graphic families |
| 8.0 | SwiftUI templates render correctly |
| 9.0+ | WidgetKit complications render correctly |
| 10.0+ | WidgetKit complications render correctly |

### Test Cases

1. **Fresh Install**: Verify complications appear in watch face gallery
2. **Data Display**: Verify step count displays correctly
3. **Goal Progress**: Verify gauge/progress displays correctly
4. **Goal Achievement**: Verify trophy symbol appears when goal reached
5. **Day Rollover**: Verify complications reset at midnight
6. **Background Refresh**: Verify complications update in background
7. **Both Identifiers**: Test both "Just Steps" and "Gauges" variants

---

## File Changes Summary

### New Files to Create

1. `Duffy WatchKit Extension/ComplicationViews.swift` - Shared SwiftUI views
2. `Duffy WatchKit Extension/DuffyWidget.swift` - WidgetKit implementation (watchOS 9+)
3. `Duffy WatchKit Extension/ProgressRingView.swift` - SwiftUI ring/gauge view

### Files to Modify

1. `Duffy WatchKit Extension/ComplicationController.swift` - Add SwiftUI template methods
2. `Duffy WatchKit Extension/ExtensionDelegate.swift` - Update refresh logic
3. `Duffy WatchKit Extension/Info.plist` - Add WidgetKit configuration
4. `Duffy WatchKit Extension/GraphicRectangularFullView.swift` - Refactor to use shared data model

### Files to Keep (Legacy Support)

All existing ClockKit template methods in `ComplicationController.swift` must be retained for watchOS 5.0-6.x support.

---

## Migration Timeline Recommendation

### Immediate (Phase 1-2)
- Create shared SwiftUI views
- Update ClockKit to use SwiftUI templates for watchOS 7+
- **Benefit**: Improved rendering, easier maintenance, no breaking changes

### Short-term (Phase 3-4)
- Add WidgetKit implementation for watchOS 9+
- Update refresh logic
- **Benefit**: Modern widget system, better performance on newer devices

### Long-term Consideration
- When ready to drop watchOS 5.0-8.x support, remove ClockKit code entirely
- Consider raising minimum deployment target to watchOS 9.0 in a future major version

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing complications | Maintain all legacy ClockKit code; use `#available` checks |
| WidgetKit data access issues | Ensure `HealthCache` is accessible from widget context via App Groups |
| Timeline refresh issues | Test background refresh thoroughly on all watchOS versions |
| Visual inconsistencies | Create shared SwiftUI views used by both ClockKit and WidgetKit |

---

## Appendix: WidgetKit Family Mapping

| ClockKit Family | WidgetKit Family (watchOS 9+) |
|-----------------|------------------------------|
| `graphicCircular` | `accessoryCircular` |
| `graphicRectangular` | `accessoryRectangular` |
| `graphicCorner` | `accessoryCorner` |
| `utilitarianSmallFlat` | `accessoryInline` |
| `modularSmall` | No direct equivalent (use `accessoryCircular`) |
| `modularLarge` | No direct equivalent (use `accessoryRectangular`) |
| `circularSmall` | `accessoryCircular` |
| `utilitarianLarge` | `accessoryInline` |
| `utilitarianSmall` | `accessoryInline` |
| `extraLarge` | `accessoryCircular` (larger) |
| `graphicBezel` | No direct equivalent |
| `graphicExtraLarge` | `accessoryCircular` (larger) |

**Note:** Some ClockKit families have no direct WidgetKit equivalent. Users on older watch faces may need to reconfigure their complications when upgrading.

---

## Conclusion

This migration plan provides a path to modernize Duffy's complications while maintaining full backward compatibility with watchOS 5.0. The phased approach allows incremental improvements without breaking existing functionality. The key is using conditional compilation (`#available`) to provide the best experience for each watchOS version while sharing as much SwiftUI code as possible between ClockKit and WidgetKit implementations.
