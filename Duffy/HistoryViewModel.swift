//
//  HistoryViewModel.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import Foundation
import Observation
import DuffyFramework

struct HistoryDetail {
    let date: Date
    let value: String
    let trophy: Trophy
}

@Observable
@MainActor
class HistoryViewModel {
    
    private enum Constants {
        static let PAGE_SIZE_DAYS: Int = 30
    }
    
    //MARK: Properties and State
    
    private var pastValues: [Date : Double] = [:]
    private var filteredDates: [Date] = []
    private var unit: LengthFormatter.Unit?
    private var filterDate: Date = Date()
    private var fetchedFromDate: Date?
    
    private(set) var canLoadMore: Bool = true
    private(set) var dataType: HistoryDataType = HistoryDataType.current
    
    var sort: DetailSortOption = .newestToOldest {
        didSet {
            DetailSortOption.sort(option: sort, dates: &filteredDates)
        }
    }
    
    private var lastDateInCache: Date {
        return pastValues.keys.sorted(by: <).first ?? Date().previousDay()
    }
    
    var currentFilterDate: Date {
        return filterDate
    }
    
    var filteredValues: [Date : Double] {
        return pastValues.filter({ filteredDates.contains($0.key) })
    }
    
    var dataTypeName: String {
        return dataType.displayName(in: unit)
    }
    
    var goal: Double? {
        return dataType.supportsGoal ? Double(HealthCache.dailyGoal()) : nil
    }
    
    var loadingTitle: String {
        return NSLocalizedString("Loading...", comment: "")
    }
    
    var title: String {
        return String(format: NSLocalizedString("Since %@", comment: ""), Globals.mediumDateFormatter().string(from: currentFilterDate))
    }
    
    var isLoadMoreHidden: Bool {
        return sort == .oldestToNewest
    }
    
    var detailCount: Int {
        return filteredDates.count
    }
    
    func detail(at index: Int) -> HistoryDetail? {
        guard index < filteredDates.count else { return nil }
        
        let date = filteredDates[index]
        guard let value = pastValues[date] else { return nil }
        
        return HistoryDetail(date: date, value: dataType.format(value), trophy: trophy(for: value))
    }
    
    private func trophy(for value: Double) -> Trophy {
        guard dataType.supportsGoal else { return .none }
        return Trophy.trophy(for: Steps(value))
    }
    
    //MARK: Data fetching
    
    func loadNextPage() async {
        await filterValues(since: filterDate.dateByAdding(days: -Constants.PAGE_SIZE_DAYS))
    }
    
    func updateDateFilter(_ filterDate: Date) async {
        await filterValues(since: filterDate.stripTime())
    }
    
    func changeDataType(_ dataType: HistoryDataType) async {
        guard dataType != self.dataType else { return }
        
        self.dataType = dataType
        HistoryDataType.current = dataType
        pastValues.removeAll()
        filteredDates.removeAll()
        fetchedFromDate = nil
        unit = nil
        canLoadMore = true
        
        await filterValues(since: filterDate)
    }
    
    private func filterValues(since startDate: Date) async {
        filterDate = startDate
        
        guard startDate < (fetchedFromDate ?? lastDateInCache) else {
            refresh()
            return
        }
        
        let previousLastCacheDate = lastDateInCache
        
        guard let fetched = await dataType.values(from: startDate, to: fetchedFromDate ?? lastDateInCache) else { return }
        
        pastValues.merge(fetched.values, uniquingKeysWith: { $1 })
        unit = fetched.unit
        fetchedFromDate = startDate
        canLoadMore = !(fetched.values.isEmpty || lastDateInCache == previousLastCacheDate)
        refresh()
    }
    
    private func refresh() {
        filteredDates = pastValues.filter({ $0.key >= filterDate }).map(\.key)
        DetailSortOption.sort(option: sort, dates: &filteredDates)
    }
    
}
