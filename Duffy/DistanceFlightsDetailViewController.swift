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
        distanceValueLabel?.textColor = Globals.lightGrayColor()
        flightsValueLabel?.textColor = Globals.lightGrayColor()
        distanceNameLabel?.textColor = Globals.lightGrayColor()
        flightsNameLabel?.textColor = Globals.lightGrayColor()
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
            else if let displayFlights = Globals.flightsFormatter().string(from: NSNumber(value: lastFlightsValue))
            {
                if (!Globals.isNarrowPhone())
                {
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Flights")
                    let attachmentString = NSAttributedString(attachment: attachment)
                    let imageAndText = NSMutableAttributedString(attributedString: attachmentString)
                    imageAndText.append(NSAttributedString(string: " "))
                    imageAndText.append(NSAttributedString(string: displayFlights))
                    flightLabel.attributedText = imageAndText
                }
                else
                {
                    flightLabel.text = displayFlights
                }
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
                var displayUnits: String
                if (lastDistanceUnits == .mile)
                {
                    if (lastDistanceValue == 1.0)
                    {
                        displayUnits = "Mile"
                    }
                    else
                    {
                        displayUnits = "Miles"
                    }
                }
                else if (lastDistanceUnits == .kilometer)
                {
                    if (lastDistanceValue == 1.0)
                    {
                        displayUnits = "Kilometer"
                    }
                    else
                    {
                        displayUnits = "Kilometers"
                    }
                }
                else
                {
                    displayUnits = LengthFormatter().unitString(fromValue: lastDistanceValue, unit: lastDistanceUnits)
                }
                
                let displayDistance = Globals.distanceFormatter().string(from: NSNumber(value: lastDistanceValue))!
                
                if (!Globals.isNarrowPhone())
                {
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(named: "Distance")
                    let attachmentString = NSAttributedString(attachment: attachment)
                    let imageAndText = NSMutableAttributedString(attributedString: attachmentString)
                    imageAndText.append(NSAttributedString(string: " "))
                    imageAndText.append(NSAttributedString(string: displayDistance))
                    distanceLabel.attributedText = imageAndText
                }
                else
                {
                    distanceLabel.text = displayDistance
                }
                
                distanceNameLabel?.text = String(format: "%@ Travelled", displayUnits)
            }
        }
    }
    
    private func valueFontSize() -> CGFloat
    {
        return min(70.0, CGFloat(floorf(Float(Double(self.view.frame.size.height) / 2.0))))
    }
}
