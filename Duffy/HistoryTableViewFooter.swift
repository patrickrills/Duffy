//
//  HistoryTableViewFooter.swift
//  Duffy
//
//  Created by Patrick Rills on 8/11/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTableViewFooter: ButtonFooterView {
    
    override init() {
        super.init()
        separatorIsVisible = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        separatorIsVisible = false
    }
    
    override var buttonAttributedText: NSAttributedString {
        return NSAttributedString(string: NSLocalizedString("Show More", comment: ""))
    }
    
}
