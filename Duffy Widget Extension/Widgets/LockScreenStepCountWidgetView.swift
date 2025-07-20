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
        Text("Duffy")
            .font(.headline)
            .fontWeight(.bold)
            .textCase(.uppercase)
            .foregroundColor(.blue)
        
        Spacer()
        
        VStack(spacing: 8) {
            Text(entry.date, format: .dateTime.month().day().hour().minute())
                    .font(.callout)

            VStack {
                Text("Steps:")
                    .foregroundColor(.secondary)
                    .font(.callout)
                Text(entry.steps.formatted())
                    .fontWeight(.bold)
            }
        }
    }
}
