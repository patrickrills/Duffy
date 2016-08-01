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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -7, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
        
        HealthKitService.getInstance().getSteps(startDate!, toEndDate: NSDate(), onRetrieve: {
            (stepsCollection: [NSDate : Int]) in
            
            dispatch_async(dispatch_get_main_queue(),{
                [weak self] (_) in
                if let weakSelf = self
                {
                    let sortedKeys = stepsCollection.keys.sort({
                        (date1: NSDate, date2: NSDate) in
                        return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                    })
                    
                    var rowTypes = [String]()
                    for _ in 1...sortedKeys.count
                    {
                        rowTypes.append("WeekRowController")
                    }
                    
                    weakSelf.scoresTable?.setRowTypes(rowTypes)
                    
                    var idx = 0
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "eee"
                    
                    let numFormatter = NSNumberFormatter()
                    numFormatter.numberStyle = .DecimalStyle
                    numFormatter.locale = NSLocale.currentLocale()
                    
                    for key in sortedKeys
                    {
                        let stepRow = weakSelf.scoresTable?.rowControllerAtIndex(idx) as! WeekRowController
                        stepRow.dateLabel?.setText(dateFormatter.stringFromDate(key).uppercaseString)
                        stepRow.stepsLabel?.setText("0")
                        
                        if let steps = stepsCollection[key]
                        {
                            stepRow.stepsLabel?.setText(numFormatter.stringFromNumber(steps))
                        }
                        
                        idx += 1
                    }
                    
                }
            })
            },
            onFailure: {
                (err: NSError?) in
                NSLog("Fail")
        })
    }
    
}
