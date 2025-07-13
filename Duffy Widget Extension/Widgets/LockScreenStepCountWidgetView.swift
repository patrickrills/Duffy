//
//  StepCountWidget.swift
//  Duffy
//
//  Created by Patrick Rills on 7/13/25.
//  Copyright © 2025 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI

struct LockScreenStepCountWidgetView : View {
    var entry: StepCountEntry

    var body: some View {
        VStack {
            HStack {
                Text("Time:")
                Text(entry.date, style: .time)
            }

            Text("Steps:")
            Text(entry.steps.formatted())
        }
    }
}
