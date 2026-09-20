//
//  GoalInstructionsView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/19/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import SwiftUI
import DuffyFramework

struct GoalInstructionsView: View {

    private enum Constants {
        static let HEADER_PADDING: CGFloat = 24.0
        static let DESCR_SPACING: CGFloat = 16.0
        static let STEP_SPACING: CGFloat = 20.0
        static let INSTRUCTIONS_SPACING: CGFloat = 8.0
        static let SCREENSHOT_WIDTH: CGFloat = 108.0
        static let SCREENSHOT_HEIGHT: CGFloat = 131.0
        static let SCREENSHOT_CORNER_RADIUS: CGFloat = 8.0
        static let CAPTION_FONT_SIZE: CGFloat = 13.0
        static let GOAL_FONT_SIZE: CGFloat = 34.0
        static let BODY_FONT_SIZE: CGFloat = 17.0
    }

    let onViewTrophies: () -> Void

    var body: some View {
        List {
            header

            ForEach(GoalInstructions.allCases, id: \.rawValue) { step in
                Section {
                    stepRow(for: step)
                }
            }

            footer
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(Constants.STEP_SPACING)
    }

    private var header: some View {
        Section {
            VStack(alignment: .leading, spacing: 0.0) {
                Text(NSLocalizedString("Your Goal", comment: "").uppercased())
                    .font(.system(size: Constants.CAPTION_FONT_SIZE))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(Globals.stepsFormatter().string(for: HealthCache.dailyGoal()) ?? "")
                    .font(.system(size: Constants.GOAL_FONT_SIZE, weight: .black))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(GoalInstructions.headline())
                    .font(.system(size: Constants.BODY_FONT_SIZE))
                    .padding(.top, Constants.DESCR_SPACING)
            }
            .padding(.vertical, Constants.HEADER_PADDING)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private func stepRow(for step: GoalInstructions) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ZStack(alignment: .topLeading) {
                Text(Globals.stepsFormatter().string(for: step.rawValue) ?? "")
                    .font(.system(size: Constants.GOAL_FONT_SIZE, weight: .black))
                    .foregroundStyle(Color(Globals.lightGrayColor()))

                Image(uiImage: step.screenshot())
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.SCREENSHOT_WIDTH, height: Constants.SCREENSHOT_HEIGHT)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SCREENSHOT_CORNER_RADIUS))
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Text(step.text())
                .font(.system(size: Constants.BODY_FONT_SIZE))
                .padding(.top, Constants.INSTRUCTIONS_SPACING)
        }
    }

    private var footer: some View {
        Section {
            Button(action: onViewTrophies) {
                Text(NSLocalizedString("See the Trophies", comment: ""))
                    .font(.body)
                    .foregroundStyle(Color(Globals.secondaryColor()))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        GoalInstructionsView(onViewTrophies: {})
            .navigationTitle(GoalInstructions.title())
    }
}
