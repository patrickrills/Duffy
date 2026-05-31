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
    @IBOutlet weak var lblSteps: WKInterfaceLabel?
    @IBOutlet weak var lblTitle: WKInterfaceLabel?
    
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Void) {
        lblTitle?.setText(NSLocalizedString("Goal!", comment: ""))
        lblSteps?.setText(NSLocalizedString("STEPS", comment: ""))
        lblHeadline?.setText(getHeadline())
        
        let formatter = Globals.integerFormatter
        let stepsGoal = formatter.string(for: HealthCache.dailyGoal())
        lblGoal?.setText(stepsGoal)
        completionHandler(.custom)
    }
    
    func getHeadline() -> String {
        let maxRandom: UInt32 = 9
        let randomNumber = Int(arc4random_uniform(maxRandom))
        
        switch randomNumber {
            case 1:
                return "You're a Shoe-per man 🦸‍♂️ or Run-der Woman 🦸‍♀️!"
            case 2:
                return "Just call you Christopher Walkin' 🐮🔔"
            case 3:
                return "You're a Steppin' Wolf 🐺"
            case 4:
                return "Nice Boot Scootin, Walker Texas Ranger 🤠🥋"
            case 5:
                return "Hey now, you’re an all star cuz you might as well be walkin' on the sun ☀️ 👊👄"
            case 6:
                return "No dragon your feet...you slayed it! 🐲🗡"
            case 7:
                return "Heck of a Jurassic Walk, Step-a-saurus 🦖🦕"
            case 8:
                return "Taking several small steps for mankind, Neil Legstrong 🌖🧑‍🚀"
            default:
                return "You've walked hard and prospered, Star Trekker 🖖"
        }
    }
}
