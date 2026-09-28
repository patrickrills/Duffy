//
//  GoalInstructionsViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/19/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import UIKit
import SwiftUI

class GoalInstructionsViewController: UIHostingController<GoalInstructionsView> {

    init() {
        super.init(rootView: GoalInstructionsView(onViewTrophies: {}))

        rootView = GoalInstructionsView(onViewTrophies: { [weak self] in
            self?.viewTrophies()
        })

        title = GoalInstructions.title()
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func viewTrophies() {
        navigationController?.pushViewController(TrophiesViewController(), animated: true)
    }
}
