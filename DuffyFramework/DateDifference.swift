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
    
    func dateByAdding(days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: self))!
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isSunday() -> Bool {
        let components = Calendar.current.dateComponents([.weekday], from: self)
        return components.weekday == 1
    }
    
    func previousDay() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: self))!
    }
    
    func nextDay() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: self))!
    }
    
    func stripTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.era, .year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
