//
//  DuffyWatchWidgetsBundle.swift
//  Duffy
//
//  Created by Patrick Rills on 7/26/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct DuffyWatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DuffyWatchWidget()
        DuffyGaugeWatchWidget()
    }
}
