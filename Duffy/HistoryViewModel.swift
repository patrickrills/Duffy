//
//  HistoryViewModel.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import Foundation
import DuffyFramework

struct HistoryDetail {
    let date: Date
    let steps: Steps
    let goal: Steps
}

@MainActor
class HistoryViewModel {
    
    private enum Constants {
        static let PAGE_SIZE_DAYS: Int = 30
    }
    
    //MARK: Properties and State
    
    private let goal = HealthCache.dailyGoal()
    private var pastSteps: [Date : Steps] = [:]
    private var filteredDates: [Date] = []
    
    private(set) var canLoadMore: Bool = true
    
    var sort: DetailSortOption = .newestToOldest {
        didSet {
            DetailSortOption.sort(option: sort, dates: &filteredDates)
        }
    }
    
    private var lastDateInCache: Date {
        return pastSteps.keys.sorted(by: <).first ?? Date().previousDay()
    }
    
    var currentFilterDate: Date {
        switch sort {
        case .newestToOldest:
            return filteredDates.last ?? Date()
        case .oldestToNewest:
            return filteredDates.first ?? Date()
        }
    }
    
    var filteredSteps: [Date : Steps] {
        return pastSteps.filter({ filteredDates.contains($0.key) })
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
        guard let steps = pastSteps[date] else { return nil }
        
        return HistoryDetail(date: date, steps: steps, goal: goal)
    }
    
    //MARK: Data fetching
    
    func loadNextPage() async {
        await filterSteps(since: currentFilterDate.dateByAdding(days: -Constants.PAGE_SIZE_DAYS))
    }
    
    func updateDateFilter(_ filterDate: Date) async {
        await filterSteps(since: filterDate.stripTime())
    }
    
    private func filterSteps(since startDate: Date) async {
        guard startDate < lastDateInCache else {
            refresh(for: startDate)
            return
        }
        
        let previousLastCacheDate = lastDateInCache
        
        switch await steps(from: startDate, to: lastDateInCache) {
        case .success(let stepsCollection):
            pastSteps.merge(stepsCollection, uniquingKeysWith: { $1 })
            canLoadMore = !(stepsCollection.isEmpty || lastDateInCache == previousLastCacheDate)
            refresh(for: startDate)
        case .failure(_):
            break
        }
    }
    
    private func steps(from startDate: Date, to endDate: Date) async -> StepsByDateResult {
        return await withCheckedContinuation { continuation in
            HealthKitService.getInstance().getSteps(from: startDate, to: endDate) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func refresh(for startDate: Date) {
        filteredDates = pastSteps.filter({ $0.key >= startDate }).map(\.key)
        DetailSortOption.sort(option: sort, dates: &filteredDates)
    }
    
}
