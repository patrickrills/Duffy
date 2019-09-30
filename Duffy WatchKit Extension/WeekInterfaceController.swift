//
//  WeekInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 7/31/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import Foundation
import DuffyWatchFramework


class WeekInterfaceController: WKInterfaceController
{
    @IBOutlet weak var stepsTable: WKInterfaceTable!
    
    override func didAppear()
    {
        super.didAppear()
        
        retrieveRecentSteps()
    }

    private func retrieveRecentSteps()
    {
        guard let startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            showErrorState()
            return
        }
        
        HealthKitService.getInstance().getSteps(startDate, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
                DispatchQueue.main.async {
                    [weak self] in
                    if let weakSelf = self {
                        let sortedKeys = stepsCollection.keys.sorted(by: {
                            (date1: Date, date2: Date) in
                            return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                        })
                    
                        if (sortedKeys.count == 0) {
                            weakSelf.showErrorState()
                            return
                        }
                    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "eee"
                    
                        let numFormatter = NumberFormatter()
                        numFormatter.numberStyle = .decimal
                        numFormatter.locale = Locale.current
                    
                        var data = [WeekRowData]()
                        
                        for key in sortedKeys {
                            let title = dateFormatter.string(from: key).uppercased()
                            var value = "0"
                            var adornment = ""
                            
                            if let steps = stepsCollection[key],
                                let formattedSteps = numFormatter.string(from: NSNumber(value: steps)) {
                                
                                value = formattedSteps
                                adornment = HealthKitService.getInstance().getAdornment(for: steps)
                            }
                            
                            data.append(WeekRowData(title: title, formattedValue: value, adornment: adornment))
                        }
                        
                        weakSelf.bindTable(to: data)
                    }
                }
            },
            onFailure: {
                [weak self] (err: Error?) in
                DispatchQueue.main.async {
                    self?.showErrorState()
                }
        })
    }
    
    private func bindTable(to data: [WeekRowData]) {
        var rowTypes = [String]()
        for _ in 1...data.count
        {
            rowTypes.append("WeekRowController")
        }
        
        stepsTable.setRowTypes(rowTypes)
        
        for (index, row) in data.enumerated() {
            let stepRow = stepsTable.rowController(at: index) as! WeekRowController
            stepRow.dateLabel?.setText(row.title)
            stepRow.stepsLabel?.setText(row.formattedValue)
            stepRow.adornmentLabel?.setText(row.adornment)
        }
    }
    
    private func showErrorState() {
        bindTable(to: [WeekRowData(title: NSLocalizedString("No Data", comment: ""), formattedValue: "", adornment: "")])
    }
    
    struct WeekRowData {
        var title: String
        var formattedValue: String
        var adornment: String
    }
}
