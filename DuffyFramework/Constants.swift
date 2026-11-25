//
//  Constants.swift
//  Duffy
//
//  Created by Patrick Rills on 1/21/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import Foundation

public enum Constants
{
    public static let isDebugMode: Bool = false
    public static let stepsGoalDefault: Steps = 10000
    public static let notificationDelayInSeconds: Int = 10
    public static let goalReachedCountForRating: Int = 3
    public static let sharedGroupName: String = "group.com.bigbluefly.Duffy"
}

public enum WatchWidgetIdentifiers {
    public static let stepsKind = "com.bigbluefly.Duffy.watch.placeholder"
    public static let gaugeKind = "com.bigbluefly.Duffy.watch.gauge"
    public static let extensionBundleIdentifier = "com.bigbluefly.Duffy.watchkitapp.watchwidgets"
}
