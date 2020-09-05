//
//  DateDifference.swift
//  Duffy
//
//  Created by Patrick Rills on 9/5/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import Foundation

public extension Date {
    
    func differenceInDays(from date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? NSNotFound
    }
    
    func previousDay() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: self))!
    }
}
