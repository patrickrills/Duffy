//
//  SummaryInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 7/31/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import Foundation
import DuffyWatchFramework

 
class SummaryInterfaceController: WKInterfaceController
{
    static let IDENTIFIER = "summaryInterfaceController"
    
    @IBOutlet weak var loadingLabel: WKInterfaceLabel!
    @IBOutlet weak var graphImage: WKInterfaceImage!
    @IBOutlet weak var stepsTable: WKInterfaceTable!
    
    private var hasDrawnChart: Bool = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if #available(watchOS 10.0, *) {
            setTitle(NSLocalizedString("Previous Week", comment: ""))
        } else {
            setTitle(NSLocalizedString("Cancel", comment: ""))
        }
    }
    
    override func didAppear() {
        super.didAppear()
        retrieveRecentSteps()
    }

    private func retrieveRecentSteps() {
        let startDate = Date().dateByAdding(days: -7)
        HealthKitService.getInstance().getSteps(from: startDate, to: Date().previousDay()) { [weak self] result in
            switch result {
            case .success(let stepsCollection):
                self?.processSteps(stepsCollection)
            case .failure(_):
                self?.showErrorState()
            }
        }
    }
    
    private func processSteps(_ stepsCollection: [Date : Steps]) {
        let numFormatter = Globals.integerFormatter
        let dateFormatter = Globals.summaryDateFormatter
        let sortedKeys = stepsCollection.keys.sorted(by: >)
        
        let data: [WeekRowData] = sortedKeys.map({
            let title = dateFormatter.string(from: $0).uppercased()
            var value = "0"
            var adornment = ""
            var goal = false

            if let steps = stepsCollection[$0],
                let formattedSteps = numFormatter.string(for: steps) {

                value = formattedSteps
                
                let trophy = Trophy.trophy(for: steps)
                adornment = trophy.symbol()
                goal = trophy != .none
            }

            return WeekRowData(title: title, formattedValue: value, adornment: adornment, isOverGoal: goal)
        })
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                if (data.count > 0) {
                    weakSelf.drawChart(for: stepsCollection.filter({ !$0.key.isToday() }))
                    weakSelf.bindTable(to: data)
                } else {
                    weakSelf.showErrorState()
                }
            }
        }
    }
    
    private let FONT_SIZE: CGFloat = 18.0
    
    private func bindTable(to data: [WeekRowData]) {
        stepsTable.setRowTypes(Array(repeating: "WeekRowController", count: data.count))
        
        let goalColor = UIColor(named: "GoalColor")!
        
        for (index, row) in data.enumerated() {
            let stepRow = stepsTable.rowController(at: index) as! WeekRowController
            let textColor: UIColor = row.isOverGoal ? goalColor : .white
            stepRow.dateLabel.setAttributedText(NSAttributedString(string: row.title, attributes: [.font : Globals.roundedFont(of: FONT_SIZE, weight: .regular), .foregroundColor : UIColor.white]))
            stepRow.stepsLabel.setAttributedText(NSAttributedString(string: (row.formattedValue + " " + row.adornment).trimmingCharacters(in: .whitespaces), attributes: [.font : Globals.roundedFont(of: FONT_SIZE, weight: .semibold), .foregroundColor : textColor]))
        }
    }
    
    private func showErrorState() {
        bindTable(to: [WeekRowData(title: "", formattedValue: NSLocalizedString("No Data", comment: ""), adornment: "", isOverGoal: false)])
        graphImage.setImage(nil)
        loadingLabel.setHidden(true)
    }
    
    private func drawChart(for data: [Date : Steps]) {
        if hasDrawnChart {
            loadingLabel.setHidden(true)
        } else {
            loadingLabel.setText(NSLocalizedString("Loading...", comment: ""))
        }
        
        let device = WKInterfaceDevice.current()
        let width: CGFloat = device.screenBounds.width
        let scale: CGFloat = device.screenScale
        
        DispatchQueue.global(qos: .userInitiated).async {
            let chartImage = ChartDrawer.drawChart(data, width: width, scale: scale)
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.graphImage.setImage(chartImage)
                weakSelf.loadingLabel.setHidden(true)
                weakSelf.hasDrawnChart = true
            }
        }
    }
    
    fileprivate struct WeekRowData {
        var title: String
        var formattedValue: String
        var adornment: String
        var isOverGoal: Bool
    }
}
