//
//  DistanceFlightsDetailViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 8/17/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class DistanceFlightsDetailViewController: DetailDataViewPageViewController
{
    @IBOutlet weak var distanceValueLabel : UILabel?
    @IBOutlet weak var flightsValueLabel : UILabel?
    @IBOutlet weak var flightsNameLabel : UILabel?
    @IBOutlet weak var distanceNameLabel : UILabel?
    
    var lastDistanceValue : DistanceTravelled = 0.0
    var lastDistanceUnits : LengthFormatter.Unit = LengthFormatter.Unit.mile
    var lastFlightsValue : FlightsClimbed = 0
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        updateFlights()
        updateDistance()
        distanceValueLabel?.textColor = Globals.lightGrayColor()
        flightsValueLabel?.textColor = Globals.lightGrayColor()
        distanceNameLabel?.textColor = Globals.lightGrayColor()
        flightsNameLabel?.textColor = Globals.lightGrayColor()
        flightsNameLabel?.text = NSLocalizedString("Flights Climbed", comment: "")
    }
    
    override func refresh()
    {
        HealthKitService.getInstance().getFlightsClimbed(for: Date()) { [weak self] result in
            switch result {
            case .success(let flightsResult):
                self?.lastFlightsValue = flightsResult.flights
                DispatchQueue.main.async {
                    self?.updateFlights()
                }
            case .failure(let error):
                LoggingService.log(error: error)
            }
        }
        
        HealthKitService.getInstance().getDistanceCovered(for: Date()) { [weak self] result in
            switch result {
            case .success(let distanceResult):
                self?.lastDistanceValue = distanceResult.distance
                self?.lastDistanceUnits = distanceResult.formatter
                
                DispatchQueue.main.async {
                    self?.updateDistance()
                }
                
            case .failure(let error):
                LoggingService.log(error: error)
            }
            
        }
    }
    
    private func updateFlights()
    {
        if let flightLabel = flightsValueLabel
        {
            flightLabel.font = UIFont.systemFont(ofSize: valueFontSize())
            
            if let displayFlights = Globals.flightsFormatter().string(from: NSNumber(value: lastFlightsValue))
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
                var displayDistanceLabel: String
                if (lastDistanceUnits == .mile)
                {
                    if (lastDistanceValue == 1.0)
                    {
                        displayDistanceLabel = NSLocalizedString("Mile Travelled", comment: "")
                    }
                    else
                    {
                        displayDistanceLabel = NSLocalizedString("Miles Travelled", comment: "")
                    }
                }
                else if (lastDistanceUnits == .kilometer)
                {
                    if (lastDistanceValue == 1.0)
                    {
                        displayDistanceLabel = NSLocalizedString("Kilometer Travelled", comment: "")
                    }
                    else
                    {
                        displayDistanceLabel = NSLocalizedString("Kilometers Travelled", comment: "")
                    }
                }
                else
                {
                    displayDistanceLabel = LengthFormatter().unitString(fromValue: lastDistanceValue, unit: lastDistanceUnits)
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
                
                distanceNameLabel?.text = displayDistanceLabel
            }
        }
    }
    
    private func valueFontSize() -> CGFloat
    {
        return min(70.0, CGFloat(floorf(Float(Double(self.view.frame.size.height) / 2.0))))
    }
}
