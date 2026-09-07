//
//  HistoryDataType.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import Foundation
import DuffyFramework

typealias HistoryValues = (values: [Date : Double], unit: LengthFormatter.Unit?)

enum HistoryDataType: String, CaseIterable {
    case steps = "steps"
    case flightsClimbed = "flightsClimbed"
    case distance = "distance"
    
    private static let SETTING_KEY: String = "historyDataType"
    
    static var current: HistoryDataType {
        get {
            guard let stored = UserDefaults.standard.string(forKey: SETTING_KEY),
                  let dataType = HistoryDataType(rawValue: stored)
            else {
                return .steps
            }
            
            return dataType
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SETTING_KEY)
        }
    }
    
    func displayName(in unit: LengthFormatter.Unit? = nil) -> String {
        switch self {
        case .steps:
            return NSLocalizedString("STEPS", comment: "")
        case .flightsClimbed:
            return NSLocalizedString("Flights", comment: "")
        case .distance:
            switch unit {
            case .kilometer:
                return NSLocalizedString("Kilometers", comment: "")
            case .mile:
                return NSLocalizedString("Miles", comment: "")
            default:
                return NSLocalizedString("Distance", comment: "")
            }
        }
    }
    
    func symbolName() -> String {
        switch self {
        case .steps:
            return "shoeprints.fill"
        case .flightsClimbed:
            return "figure.stairs"
        case .distance:
            return "point.topleft.down.to.point.bottomright.curvepath"
        }
    }
    
    var supportsGoal: Bool {
        return self == .steps
    }
    
    func formatter() -> NumberFormatter {
        switch self {
        case .steps:
            return Globals.stepsFormatter()
        case .flightsClimbed:
            return Globals.flightsFormatter()
        case .distance:
            return Globals.distanceFormatter()
        }
    }
    
    func format(_ value: Double) -> String {
        return formatter().string(for: value) ?? ""
    }
    
    //MARK: Data fetching
    
    func values(from startDate: Date, to endDate: Date) async -> HistoryValues? {
        switch self {
        case .steps:
            return await withCheckedContinuation { continuation in
                HealthKitService.getInstance().getSteps(from: startDate, to: endDate) { result in
                    switch result {
                    case .success(let steps):
                        continuation.resume(returning: (values: steps.mapValues({ Double($0) }), unit: nil))
                    case .failure(_):
                        continuation.resume(returning: nil)
                    }
                }
            }
            
        case .flightsClimbed:
            return await withCheckedContinuation { continuation in
                HealthKitService.getInstance().getFlightsClimbed(from: startDate, to: endDate) { result in
                    switch result {
                    case .success(let flights):
                        continuation.resume(returning: (values: flights.mapValues({ Double($0) }), unit: nil))
                    case .failure(_):
                        continuation.resume(returning: nil)
                    }
                }
            }
            
        case .distance:
            return await withCheckedContinuation { continuation in
                HealthKitService.getInstance().getDistanceCovered(from: startDate, to: endDate) { result in
                    switch result {
                    case .success(let distance):
                        continuation.resume(returning: (values: distance.values, unit: distance.formatter))
                    case .failure(_):
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}
