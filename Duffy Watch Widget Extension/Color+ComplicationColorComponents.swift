//
//  Color+Com.swift
//  Duffy
//
//  Created by Patrick Rills on 7/26/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import SwiftUI
import DuffyWatchFramework

extension Color {
    init(complicationColor color: ComplicationColorComponents) {
        self.init(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}
