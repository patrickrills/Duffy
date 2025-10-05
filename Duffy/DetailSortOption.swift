//
//  DetailSortOption.swift
//  Duffy
//
//  Created by Patrick Rills on 3/5/23.
//  Copyright © 2023 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

enum DetailSortOption: String, CaseIterable {
    case newestToOldest = "newestToOldest"
    case oldestToNewest = "oldestToNewest"
    
    static func sort(option: DetailSortOption, dates: inout [Date]) {
        dates.sort(by: { sort(option: option, date1: $0, date2: $1) })
    }
    
    private static func sort(option: DetailSortOption, date1: Date, date2: Date) -> Bool {
        switch option {
        case .newestToOldest:
            return date1 > date2
        case .oldestToNewest:
            return date1 < date2
        }
    }
    
    func displayText() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: String(format: "%@ ", NSLocalizedString("Sort", comment: "")))
        let symbolName = self.symbolName()
        let symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: UIFont.labelFontSize))
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        let symbolTextAttachment = NSTextAttachment()
        symbolTextAttachment.image = symbolImage
        let attachmentString = NSMutableAttributedString(attachment: symbolTextAttachment)
        attributedText.append(attachmentString)
        return attributedText
    }
    
    func menuOptionText() -> String {
        switch self {
        case .newestToOldest:
            return NSLocalizedString("Newest to Oldest", comment: "")
        case .oldestToNewest:
            return NSLocalizedString("Oldest to Newest", comment: "")
        }
    }
    
    func symbolName() -> String {
        switch self {
        case .newestToOldest:
            return "arrow.down"
        case .oldestToNewest:
            return "arrow.up"
        }
    }
}
