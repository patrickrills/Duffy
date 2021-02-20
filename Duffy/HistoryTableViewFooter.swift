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
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        separatorIsVisible = false
        buttonAttributedText = NSAttributedString(string: NSLocalizedString("Show More", comment: ""))
    }
    
}
