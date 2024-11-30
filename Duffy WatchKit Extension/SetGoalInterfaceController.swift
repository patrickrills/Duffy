//
//  SetGoalInterfaceController.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 11/21/20.
//  Copyright © 2020 Big Blue Fly. All rights reserved.
//

import WatchKit
import DuffyWatchFramework

class SetGoalInterfaceController: WKInterfaceController
{
    public static let IDENTIFIER = "SetGoalInterfaceController"
 
    public static func populateGoalItems(includeTitle: Bool) -> (options: [Steps], pickerItems: [WKPickerItem]) {
        var items: [WKPickerItem] = []
        var options: [Steps] = []
        
        for i in stride(from: 500, to: 80250, by: 250) {
            let opt = WKPickerItem()
            if includeTitle {
                opt.title = Globals.integerFormatter.string(for: i)
            }
            items.append(opt)
            options.append(Steps(i))
        }
        
        return (options: options, pickerItems: items)
    }
    
    @IBOutlet weak var invisiblePicker: WKInterfacePicker!
    @IBOutlet weak var minusImage: WKInterfaceImage!
    @IBOutlet weak var plusImage: WKInterfaceImage!
    @IBOutlet weak var selectedStepsLabel: WKInterfaceLabel!
    @IBOutlet weak var descrStepsLabel: WKInterfaceLabel!
    @IBOutlet weak var setGoalButtonLabel: WKInterfaceLabel!
    
    private var options: [Steps] = []
    private var selectedGoal: Steps = 0
    private var selectedIndex: Int = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if #available(watchOS 10.0, *) {
            setTitle(nil)
        } else {
            setTitle(NSLocalizedString("Cancel", comment: ""))
        }
        
        setGoalButtonLabel.setText(NSLocalizedString("Set Goal", comment: ""))
        
        let items = SetGoalInterfaceController.populateGoalItems(includeTitle: false)
        options = items.options
        invisiblePicker.setItems(items.pickerItems)
        
        if #available(watchOS 6.0, *) {
            let buttonConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 28.0, weight: .medium))
            minusImage.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: buttonConfig))
            plusImage.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: buttonConfig))
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        selectedGoal = HealthCache.dailyGoal()
        
        if let i = options.firstIndex(of: selectedGoal) {
            invisiblePicker.setSelectedItemIndex(i)
        }
    }
    
    @IBAction private func minusPressed() {
        stepIndex(step: -1)
    }
    
    @IBAction private func plusPressed() {
        stepIndex(step: 1)
    }
    
    private func stepIndex(step: Int) {
        let prosposedIndex = selectedIndex + step
        if options.indices.contains(prosposedIndex) {
            invisiblePicker.setSelectedItemIndex(prosposedIndex)
        }
    }
    
    @IBAction private func pickerIndexChanged(index: Int) {
        selectedIndex = index
        selectedGoal = options[index]
        updateDisplayedSteps()
    }
    
    @IBAction func savePressed() {
        HealthCache.saveDailyGoal(selectedGoal)
        ComplicationController.refreshComplication()
        dismiss()
    }
    
    private func updateDisplayedSteps() {
        guard let goalFormatted = Globals.integerFormatter.string(for: selectedGoal) else { return }
        
        if #available(watchOS 6.0, *) {
            let valueFontSize: CGFloat = 44.0
            let descrFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
            let valueFont = Globals.roundedFont(of: valueFontSize, weight: .black)
            let descrFont = Globals.roundedFont(of: descrFontSize, weight: .regular)
            
            selectedStepsLabel.setAttributedText(NSAttributedString(string: goalFormatted, attributes: [ .font : valueFont ]))
            descrStepsLabel.setAttributedText(NSAttributedString(string: NSLocalizedString("STEPS", comment: ""), attributes: [.font : descrFont]))
        } else {
            selectedStepsLabel.setText(goalFormatted)
        }
    }
}
