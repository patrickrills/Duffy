//
//  Types.swift
//  Duffy
//
//  Created by Patrick Rills on 8/14/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public typealias Steps = UInt
public typealias Hour = UInt
public typealias FlightsClimbed = UInt
public typealias DistanceTravelled = Double
public typealias StepsByDateResult = Result<[Date : Steps], HealthKitError>
public typealias StepsByHourResult = Result<(day: Date, stepsByHour: [Hour : Steps]), HealthKitError>
public typealias StepsForDayResult = Result<(day: Date, steps: Steps), HealthKitError>
public typealias FlightsForDayResult = Result<(day: Date, flights: FlightsClimbed), HealthKitError>
public typealias DistanceForDayResult = Result<(day: Date, formatter: LengthFormatter.Unit, distance: DistanceTravelled), HealthKitError>
