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
    @IBOutlet weak var loadingLabel: WKInterfaceLabel!
    @IBOutlet weak var graphImage: WKInterfaceImage!
    @IBOutlet weak var stepsTable: WKInterfaceTable!
    
    private var hasDrawnChart: Bool = false
    
    override func willActivate() {
        super.willActivate()
        
        if !DebugService.isDebugModeEnabled() {
            loadingLabel.setHidden(true)
            graphImage.setHidden(true)
        }
    }
    
    override func didAppear() {
        super.didAppear()
        retrieveRecentSteps()
    }

    private func retrieveRecentSteps() {
        guard let startDate = HealthKitService.getInstance().earliestQueryDate() else {
            showErrorState()
            return
        }
        
        HealthKitService.getInstance().getSteps(from: startDate, to: Date()) { [weak self] result in
            switch result {
            case .success(let stepsCollection):
                self?.processSteps(stepsCollection)
            case .failure(_):
                self?.showErrorState()
            }
        }
    }
    
    private func processSteps(_ stepsCollection: [Date : Steps]) {
        let numFormatter = InterfaceController.getNumberFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "eee"
        
        let sortedKeys = stepsCollection.keys.sorted(by: >)
        
        let data: [WeekRowData] = sortedKeys.map({
            let title = dateFormatter.string(from: $0).uppercased()
            var value = "0"
            var adornment = ""

            if let steps = stepsCollection[$0],
                let formattedSteps = numFormatter.string(for: steps) {

                value = formattedSteps
                adornment = Trophy.trophy(for: steps).symbol()
            }

            return WeekRowData(title: title, formattedValue: value, adornment: adornment)
        })
        
        DispatchQueue.main.async { [weak self] in
            if let weakSelf = self {
                if (data.count > 0) {
                    weakSelf.drawChart(for: stepsCollection)
                    weakSelf.bindTable(to: data)
                } else {
                    weakSelf.showErrorState()
                }
            }
        }
    }
    
    private func bindTable(to data: [WeekRowData]) {
        stepsTable.setRowTypes(Array(repeating: "WeekRowController", count: data.count))
        
        for (index, row) in data.enumerated() {
            let stepRow = stepsTable.rowController(at: index) as! WeekRowController
            stepRow.dateLabel?.setText(row.title)
            stepRow.stepsLabel?.setText(row.formattedValue)
            stepRow.adornmentLabel?.setText(row.adornment)
        }
    }
    
    private func showErrorState() {
        bindTable(to: [WeekRowData(title: NSLocalizedString("No Data", comment: ""), formattedValue: "", adornment: "")])
        graphImage.setImage(nil)
    }
    
    private func drawChart(for data: [Date : Steps]) {
        if DebugService.isDebugModeEnabled() {
            if hasDrawnChart {
                loadingLabel.setHidden(true)
            } else {
                loadingLabel.setText(NSLocalizedString("Loading...", comment: ""))
            }
            
            let width: CGFloat = WKInterfaceDevice.current().screenBounds.width
            
            DispatchQueue.global(qos: .userInitiated).async {
                let chartImage = ChartDrawer.drawChart(width: width)
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }
                    weakSelf.graphImage.setImage(chartImage)
                    weakSelf.loadingLabel.setHidden(true)
                    weakSelf.hasDrawnChart = true
                }
            }
        }
    }
    
    struct WeekRowData {
        var title: String
        var formattedValue: String
        var adornment: String
    }
}
