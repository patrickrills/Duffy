//
//  EditGoalInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 4/18/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import WatchKit
import DuffyWatchFramework

class LegacyEditGoalInterfaceController: WKInterfaceController
{
    public static let IDENTIFIER = "LegacyEditGoalInterfaceController"
    
    @IBOutlet weak var goalOptionsList: WKInterfacePicker!
    @IBOutlet weak var goalButton: WKInterfaceButton!
    
    private var stepsGoal: Steps = 0
    private var options: [Steps] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setTitle(NSLocalizedString("Cancel", comment: ""))
        goalButton.setTitle(NSLocalizedString("Set Goal", comment: ""))
        
        let items = SetGoalInterfaceController.populateGoalItems(includeTitle: true)
        options = items.options
        goalOptionsList.setItems(items.pickerItems)
    }
    
    override func willActivate() {
        super.willActivate()
        
        stepsGoal = HealthCache.dailyGoal()
        
        if let i = options.firstIndex(of: stepsGoal) {
            goalOptionsList.setSelectedItemIndex(i)
        }
    }
    
    @IBAction func pickerChanged(value: Int) {
        stepsGoal = options[value]
    }

    @IBAction func savePressed() {
        HealthCache.saveDailyGoal(stepsGoal)
        dismiss()
    }
}
