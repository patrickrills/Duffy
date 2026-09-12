//
//  HistoryHostingController.swift
//  Duffy
//
//  Created by Patrick Rills on 9/7/26.
//  Copyright © 2026 Big Blue Fly. All rights reserved.
//

import UIKit
import SwiftUI

class HistoryHostingController: UIHostingController<HistoryView> {
    
    init() {
        super.init(rootView: HistoryView(onShowFilter: { _, _ in }))
        modalPresentationStyle = .fullScreen
        
        rootView = HistoryView(onShowFilter: { [weak self] selectedDate, onDateSelected in
            let filter = HistoryFilterView(selectedDate: selectedDate, onDateSelected: { [weak self] filterDate in
                onDateSelected(filterDate)
                self?.navigationController?.popViewController(animated: true)
            })
            
            self?.navigationController?.pushViewController(UIHostingController(rootView: filter), animated: true)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
