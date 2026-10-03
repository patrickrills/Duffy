//
//  HistoryHostingController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import UIKit
import SwiftUI

class HistoryHostingController: UIHostingController<HistoryView> {
    
    init() {
        super.init(rootView: HistoryView())
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
