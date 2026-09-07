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

protocol HistoryViewModelDelegate: AnyObject {
    func historyDataDidChange()
    func historyLoadingStateDidChange()
}

class HistoryViewModel {
    
    private enum Constants {
        static let PAGE_SIZE_DAYS: Int = 30
    }
    
    //MARK: Properties and State
    
    weak var delegate: HistoryViewModelDelegate?
    
    private let goal = HealthCache.dailyGoal()
    private var pastSteps: [Date : Steps] = [:]
    private var filteredDates: [Date] = []
    private var isLoading: Bool = false
    
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
    
    var title: String {
        return isLoading
            ? NSLocalizedString("Loading...", comment: "")
            : String(format: NSLocalizedString("Since %@", comment: ""), Globals.mediumDateFormatter().string(from: currentFilterDate))
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
    
    func loadNextPage() {
        filterSteps(since: currentFilterDate.dateByAdding(days: -Constants.PAGE_SIZE_DAYS))
    }
    
    func updateDateFilter(_ filterDate: Date) {
        filterSteps(since: filterDate.stripTime())
    }
    
    private func filterSteps(since startDate: Date) {
        toggleLoading(true)
        
        if startDate >= lastDateInCache {
            refresh(for: startDate)
        } else {
            let previousLastCacheDate = lastDateInCache
            
            HealthKitService.getInstance().getSteps(from: startDate, to: lastDateInCache) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let stepsCollection):
                        self.pastSteps.merge(stepsCollection, uniquingKeysWith: { $1 })
                        self.canLoadMore = !(stepsCollection.isEmpty || self.lastDateInCache == previousLastCacheDate)
                        self.refresh(for: startDate)
                    case .failure(_):
                        self.toggleLoading(false)
                    }
                }
            }
        }
    }
    
    private func refresh(for startDate: Date) {
        filteredDates = pastSteps.filter({ $0.key >= startDate }).map(\.key)
        DetailSortOption.sort(option: sort, dates: &filteredDates)
        delegate?.historyDataDidChange()
        toggleLoading(false)
    }
    
    private func toggleLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        delegate?.historyLoadingStateDidChange()
    }
    
}
