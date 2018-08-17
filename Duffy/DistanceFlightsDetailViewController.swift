//
//  DistanceFlightsDetailViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/17/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class DistanceFlightsDetailViewController: UIViewController
{
    @IBOutlet weak var distanceValueLabel : UILabel?
    @IBOutlet weak var flightsValueLabel : UILabel?
    @IBOutlet weak var flightsNameLabel : UILabel?
    @IBOutlet weak var distanceNameLabel : UILabel?
    
    var lastDistanceValue : Double = 0.0
    var lastDistanceUnits : LengthFormatter.Unit = LengthFormatter.Unit.mile
    var lastFlightsValue : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize()
    {
        distanceValueLabel?.textColor = UIColor.lightGray
        flightsValueLabel?.textColor = UIColor.lightGray
        distanceNameLabel?.textColor = UIColor.lightGray
        flightsNameLabel?.textColor = UIColor.lightGray
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        updateFlights()
        updateDistance()
    }
    
    func refresh()
    {
        HealthKitService.getInstance().getFlightsClimbed(Date(), onRetrieve: {
            [weak self] flights, forDate in
            
            self?.lastFlightsValue = flights
            
            DispatchQueue.main.async
            {
                [weak self] in
                self?.updateFlights()
            }
            
        }, onFailure: nil)
        
        HealthKitService.getInstance().getDistanceCovered(Date(), onRetrieve: {
            [weak self] distance, lengthUnit, forDate in
            
            self?.lastDistanceValue = distance
            self?.lastDistanceUnits = lengthUnit
            
            DispatchQueue.main.async
            {
                [weak self] in
                self?.updateDistance()
            }
            
        }, onFailure: nil)
    }
    
    private func updateFlights()
    {
        if let flightLabel = flightsValueLabel
        {
            flightLabel.font = UIFont.systemFont(ofSize: valueFontSize())
            
            if (lastFlightsValue < 0)
            {
                flightLabel.text = "?"
            }
            else
            {
                flightLabel.text = Globals.flightsFormatter().string(from: NSNumber(value: lastFlightsValue))
            }
        }
    }
    
    private func updateDistance()
    {
        if let distanceLabel = distanceValueLabel
        {
            distanceLabel.font = UIFont.systemFont(ofSize: valueFontSize())
            
            if (lastDistanceValue < 0)
            {
                distanceLabel.text = "?"
            }
            else
            {
                let displayDistance = Globals.distanceFormatter().string(from: NSNumber(value: lastDistanceValue))!
                let displayUnits = LengthFormatter().unitString(fromValue: lastDistanceValue, unit: lastDistanceUnits)
                let combined = String(format: "%@ %@", displayDistance, displayUnits)
                let attributed = NSMutableAttributedString(string: combined)
                let unitFontSize = CGFloat(floorf(Float(valueFontSize() / 2.0)))
                attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: unitFontSize), range: NSMakeRange(displayDistance.count, combined.count - displayDistance.count))
                distanceLabel.attributedText = attributed
            }
        }
    }
    
    private func valueFontSize() -> CGFloat
    {
        return min(70.0, CGFloat(floorf(Float(Double(self.view.frame.size.height) / 2.0))))
    }
}
