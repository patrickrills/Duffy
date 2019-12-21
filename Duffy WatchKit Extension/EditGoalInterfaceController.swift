//
//  EditGoalInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 4/18/17.
//  Copyright © 2017 Big Blue Fly. All rights reserved.
//

import WatchKit
import DuffyWatchFramework

class EditGoalInterfaceController: WKInterfaceController
{
    @IBOutlet weak var goalOptionsList: WKInterfacePicker?
    private var stepsGoal: Int = 0
    private var options: [Int] = []
    
    override func awake(withContext context: Any?)
    {
        super.awake(withContext: context)
        
        if let picker = goalOptionsList
        {
            var items: [WKPickerItem] = []
            for i in stride(from: 500, to: 80250, by: 250)
            {
                let opt = WKPickerItem()
                opt.title = InterfaceController.getNumberFormatter().string(from: NSNumber(value: i))
                items.append(opt)
                options.append(i)
            }
            
            picker.setItems(items)
        }
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        stepsGoal = HealthCache.getStepsDailyGoal()
        
        if let i = options.firstIndex(of: stepsGoal)
        {
            goalOptionsList?.setSelectedItemIndex(i)
        }
    }
    
    @IBAction func pickerChanged(value: Int)
    {
        stepsGoal = options[value]
    }

    @IBAction func savePressed()
    {
        HealthCache.saveStepsGoalToCache(stepsGoal)
        dismiss()
    }
}
