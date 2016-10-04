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
    @IBOutlet weak var scoresTable: WKInterfaceTable?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        bindTableToWeek()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func bindTableToWeek()
    {
        let startDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -7, to: Date(), options: NSCalendar.Options(rawValue: 0))
        
        HealthKitService.getInstance().getSteps(startDate!, toEndDate: Date(), onRetrieve: {
            (stepsCollection: [Date : Int]) in
            
            DispatchQueue.main.async(execute: {
                [weak self] (_) in
                if let weakSelf = self
                {
                    let sortedKeys = stepsCollection.keys.sorted(by: {
                        (date1: Date, date2: Date) in
                        return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                    })
                    
                    var rowTypes = [String]()
                    for _ in 1...sortedKeys.count
                    {
                        rowTypes.append("WeekRowController")
                    }
                    
                    weakSelf.scoresTable?.setRowTypes(rowTypes)
                    
                    var idx = 0
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "eee"
                    
                    let numFormatter = NumberFormatter()
                    numFormatter.numberStyle = .decimal
                    numFormatter.locale = Locale.current
                    
                    for key in sortedKeys
                    {
                        let stepRow = weakSelf.scoresTable?.rowController(at: idx) as! WeekRowController
                        stepRow.dateLabel?.setText(dateFormatter.string(from: key).uppercased())
                        stepRow.stepsLabel?.setText("0")
                        
                        if let steps = stepsCollection[key]
                        {
                            stepRow.stepsLabel?.setText(numFormatter.string(from: NSNumber(value: steps)))
                        }
                        
                        idx += 1
                    }
                    
                }
            })
            },
            onFailure: {
                (err: Error?) in
                NSLog("Fail")
        })
    }
    
}
