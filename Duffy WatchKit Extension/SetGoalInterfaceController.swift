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
                opt.title = InterfaceController.getNumberFormatter().string(for: i)
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
    
    private var options: [Steps] = []
    private var selectedGoal: Steps = 0
    private var selectedIndex: Int = 0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let items = SetGoalInterfaceController.populateGoalItems(includeTitle: false)
        options = items.options
        invisiblePicker.setItems(items.pickerItems)
        
        if #available(watchOS 6.0, *) {
            let buttonConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30.0))
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
        guard let goalFormatted = InterfaceController.getNumberFormatter().string(for: selectedGoal) else { return }
        
        if #available(watchOS 6.0, *) {
            let valueFontSize: CGFloat = 44.0
            let descrFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
            if let valueFontDescriptor = UIFont.systemFont(ofSize: valueFontSize, weight: .black).fontDescriptor.withDesign(.rounded),
               let descrFontDescriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withDesign(.rounded)
            {
                selectedStepsLabel.setAttributedText(NSAttributedString(string: goalFormatted, attributes: [ .font : UIFont(descriptor: valueFontDescriptor, size: valueFontSize) ]))
                descrStepsLabel.setAttributedText(NSAttributedString(string: NSLocalizedString("STEPS", comment: ""), attributes: [.font : UIFont(descriptor: descrFontDescriptor, size: descrFontSize)]))
                return
            }
        }
        
        selectedStepsLabel.setText(goalFormatted)
    }
}
