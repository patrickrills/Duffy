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
    @IBOutlet weak var stepsTable: WKInterfaceTable?
    
    override func didAppear()
    {
        super.didAppear()
        
        bindTableToWeek()
    }

    func bindTableToWeek()
    {
        let startDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -14, to: Date(), options: NSCalendar.Options(rawValue: 0))
        
        HealthKitService.getInstance().getSteps(startDate!, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
            DispatchQueue.main.async {
                [weak self] in
                if let weakSelf = self
                {
                    let sortedKeys = stepsCollection.keys.sorted(by: {
                        (date1: Date, date2: Date) in
                        return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                    })
                    
                    if (sortedKeys.count == 0) { return }
                    
                    var rowTypes = [String]()
                    for _ in 1...sortedKeys.count
                    {
                        rowTypes.append("WeekRowController")
                    }
                    
                    weakSelf.stepsTable?.setRowTypes(rowTypes)
                    
                    var idx = 0
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "eee"
                    
                    let numFormatter = NumberFormatter()
                    numFormatter.numberStyle = .decimal
                    numFormatter.locale = Locale.current
                    
                    for key in sortedKeys
                    {
                        let stepRow = weakSelf.stepsTable?.rowController(at: idx) as! WeekRowController
                        stepRow.dateLabel?.setText(dateFormatter.string(from: key).uppercased())
                        stepRow.stepsLabel?.setText("0")
                        
                        if let steps = stepsCollection[key]
                        {
                            stepRow.stepsLabel?.setText(numFormatter.string(from: NSNumber(value: steps)))
                            stepRow.adornmentLabel?.setText(HealthKitService.getInstance().getAdornment(for: steps))
                        }
                        
                        idx += 1
                    }
                }
                }
            },
            onFailure: {
                (err: Error?) in
                DispatchQueue.main.async {
                    print("error: \(err?.localizedDescription ?? "no error")")
                }
        })
    }
    
}
