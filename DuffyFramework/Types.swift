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
public typealias StepsByDateResult = Result<[Date : Steps], HealthKitError>
public typealias StepsByHourResult = Result<(day: Date, stepsByHour: [Hour : Steps]), HealthKitError>
