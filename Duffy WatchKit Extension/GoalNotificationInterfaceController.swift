//
//  GoalNotificationInterfaceController.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/18/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import Foundation
import WatchKit
import DuffyWatchFramework
import UserNotifications

class GoalNotificationInterfaceController: WKUserNotificationInterfaceController
{
    @IBOutlet weak var lblHeadline: WKInterfaceLabel?
    @IBOutlet weak var lblGoal: WKInterfaceLabel?
    
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Void)
    {
        lblHeadline?.setText(getHeadline())
        
        let formatter = InterfaceController.getNumberFormatter()
        let stepsGoal = formatter.string(from: NSNumber(value: HealthCache.getStepsDailyGoal()))
        lblGoal?.setText(stepsGoal)
        completionHandler(.custom)
    }
    
    func getHeadline() -> String
    {
        let maxRandom: UInt32 = 4
        let randomNumber = Int(arc4random_uniform(maxRandom))
        
        switch randomNumber
        {
            case 1:
                if #available(watchOS 5.0, *) {
                    return "You're a Shoe-per man 🦸‍♂️ or Run-der Woman 🦸‍♀️!"
                } else {
                     return "You're a Shoe-per man or Run-der Woman! 👑"
                }
            case 2:
                return "Just call you Christopher Walkin' 🐮🔔"
            case 3:
                return "You're a Steppin' Wolf 🐺"
            default:
                return "You've walked hard and prospered, Star Trekker 🖖"
        }
    }
}
