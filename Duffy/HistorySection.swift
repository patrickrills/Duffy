//
//  HistorySection.swift
//  Duffy
//
//  Created by Patrick Rills on 3/19/23.
//  Copyright © 2023 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

enum HistorySection: Int, CaseIterable {
    case chart, summary, details
    
    func optionsMenu(handler: HistorySectionOptionHandler) -> UIMenu? {
        switch self {
        case .chart:
            let lines: [HistoryTrendChartOption] = [.actualDataLine, .trendLine]
            let indicators: [HistoryTrendChartOption] = [.goalIndicator, .averageIndicator]
            let handleOption: (UIAction) -> (Void) = { [weak handler] action in
                if let selectedOption = HistoryTrendChartOption(rawValue: action.identifier.rawValue),
                    let handler = handler
                {
                    handler.handleHistoryTrendChartOption(selectedOption)
                }
            }
            
            let lineMenuOptions = lines.map {
                UIAction(title: $0.displayName(), image: UIImage(systemName: $0.symbolName()), identifier: UIAction.Identifier($0.rawValue), state: $0.isEnabled() ? .on : .off) { action in handleOption(action) }
            }
            
            let indicatorMenuOptions = indicators.map {
                UIAction(title: $0.displayName(), image: UIImage(systemName: $0.symbolName()), identifier: UIAction.Identifier($0.rawValue), state: $0.isEnabled() ? .on : .off) { action in handleOption(action) }
            }
            
            return UIMenu(title: "", children: [
                UIMenu(title: NSLocalizedString("Lines", comment: "Title of section of options to change how the lines on a chart are drawn"), options: .displayInline, children: lineMenuOptions),
                UIMenu(title: NSLocalizedString("Indicators", comment: "Title of section of options changing which markers are shown on a chart/graph"), options: .displayInline, children: indicatorMenuOptions)
            ])
            
        case .summary:
            return nil
            
        case .details:
            let menuActions = DetailSortOption.allCases.map {
                UIAction(title: $0.menuOptionText(), image: UIImage(systemName: $0.symbolName()), identifier: UIAction.Identifier($0.rawValue), state: (handler.isDetailSortOptionEnabled($0) ? .on : .off)) { [weak handler] action in
                    if let selectedSort = DetailSortOption(rawValue: action.identifier.rawValue),
                        let handler = handler
                    {
                        handler.handleDetailSortOption(selectedSort)
                    }
                }
            }

            return UIMenu(title: "", children: menuActions)
            
        }
    }
}

protocol HistorySectionOptionHandler: AnyObject {
    func handleHistoryTrendChartOption(_ option: HistoryTrendChartOption)
    func handleDetailSortOption(_ option: DetailSortOption)
    func isDetailSortOptionEnabled(_ option: DetailSortOption) -> Bool
}
