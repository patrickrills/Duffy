//
//  ComplicationController.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import ClockKit
import DuffyWatchFramework

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void)
    {
        handler(.ShowOnLockScreen)
    }
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void)
    {
        handler([.None])
    }
    
    func requestedUpdateDidBegin()
    {
        ComplicationController.refreshComplication()
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void))
    {
        // Call the handler with the current timeline entry
        var entry: CLKComplicationTimelineEntry?
        let steps = HealthCache.getStepsFromCache(NSDate())
        
        if (complication.family == .ModularSmall)
        {
            entry = getEntryForModularSmall(NSNumber(integer: steps))
        }
        else if (complication.family == .ModularLarge)
        {
            entry = getEntryForModularLarge(NSNumber(integer: steps))
        }
        else if (complication.family == .CircularSmall)
        {
            entry = getEntryForCircularSmall(NSNumber(integer: steps))
        }
        else if (complication.family == .UtilitarianLarge)
        {
            entry = getEntryForUtilitarianLarge(NSNumber(integer: steps))
        }
        else if (complication.family == .UtilitarianSmall)
        {
            entry = getEntryForUtilitarianSmall(NSNumber(integer: steps))
        }
        
        handler(entry)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void)
    {
        handler(NSDate(timeIntervalSinceNow: 60*30))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void)
    {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate?
        if (complication.family == .ModularSmall)
        {
            template = getTemplateForModularSmall(NSNumber(integer: 0))
        }
        else if (complication.family == .ModularLarge)
        {
            template = getTemplateForModularLarge(NSNumber(integer: 0))
        }
        else if (complication.family == .CircularSmall)
        {
            template = getTemplateForCircularSmall(NSNumber(integer: 0))
        }
        else if (complication.family == .UtilitarianLarge)
        {
            template = getTemplateForUtilitarianLarge(NSNumber(integer: 0))
        }
        else if (complication.family == .UtilitarianSmall)
        {
            template = getTemplateForUtilitarianSmall(NSNumber(integer: 0))
        }
        
        handler(template)
    }
    
    //MARK: - templates for various complication types
    
    func getEntryForModularSmall(totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let small = getTemplateForModularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: small)
    }
    
    func getTemplateForModularSmall(totalSteps: NSNumber) -> CLKComplicationTemplateModularSmallStackText
    {
        let smallStack = CLKComplicationTemplateModularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = String(format: "%@", formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        line1.tintColor = UIColor.whiteColor()
        smallStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 103.0/255.0, green: 171.0/255.0, blue: 229.0/255.0, alpha: 1)
        smallStack.line2TextProvider = line2
        
        return smallStack
    }
    
    func getEntryForModularLarge(totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let large = getTemplateForModularLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: large)
    }
    
    func getTemplateForModularLarge(totalSteps: NSNumber) -> CLKComplicationTemplateModularLargeTallBody
    {
        let tall = CLKComplicationTemplateModularLargeTallBody()
        
        let header = CLKSimpleTextProvider()
        header.text = NSLocalizedString("Steps", comment: "")
        header.shortText = header.text
        header.tintColor = UIColor(red: 103.0/255.0, green: 171.0/255.0, blue: 229.0/255.0, alpha: 1)
        tall.headerTextProvider = header
        
        let body = CLKSimpleTextProvider()
        body.text = String(format: "%@", formatStepsForLarge(totalSteps))
        body.shortText = body.text
        body.tintColor = UIColor.whiteColor()
        tall.bodyTextProvider = body
        
        return tall
    }
    
    func getEntryForCircularSmall(totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let circular = getTemplateForCircularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: circular)
    }
    
    func getTemplateForCircularSmall(totalSteps: NSNumber) -> CLKComplicationTemplateCircularSmallStackText
    {
        let circularStack = CLKComplicationTemplateCircularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = String(format: "%@", formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        line1.tintColor = UIColor.whiteColor()
        circularStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 103.0/255.0, green: 171.0/255.0, blue: 229.0/255.0, alpha: 1)
        circularStack.line2TextProvider = line2
        
        return circularStack
    }
    
    func getEntryForUtilitarianLarge(totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let large = getTemplateForUtilitarianLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: large)
    }
    
    func getTemplateForUtilitarianLarge(totalSteps: NSNumber) -> CLKComplicationTemplateUtilitarianLargeFlat
    {
        let flat = CLKComplicationTemplateUtilitarianLargeFlat()
        let formattedStepsLong = formatStepsForLarge(totalSteps)
        let formattedStepsShort = formatStepsForSmall(totalSteps)
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: "%@ STEPS", formattedStepsLong)
        text.shortText = String(format: "%@ STEPS", formattedStepsShort)
        text.tintColor = UIColor.whiteColor()
        flat.textProvider = text
        
        return flat
    }
    
    func getEntryForUtilitarianSmall(totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let small = getTemplateForUtilitarianSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: small)
    }
    
    func getTemplateForUtilitarianSmall(totalSteps: NSNumber) -> CLKComplicationTemplateUtilitarianSmallFlat
    {
        let flat = CLKComplicationTemplateUtilitarianSmallFlat()
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: "%@ STEPS", formatStepsForSmall(totalSteps))
        text.shortText = text.text
        text.tintColor = UIColor.whiteColor()
        flat.textProvider = text
        
        return flat
    }
    
    func formatStepsForLarge(totalSteps: NSNumber) -> String
    {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.locale = NSLocale.currentLocale()
        if let format = numberFormatter.stringFromNumber(totalSteps)
        {
            return format
        }
        
        return "0"
    }
    
    func formatStepsForSmall(totalSteps: NSNumber) -> String
    {
        if (totalSteps.integerValue >= 1000)
        {
            let totalStepsReduced = NSNumber(double: totalSteps.doubleValue / 1000.0)
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            numberFormatter.locale = NSLocale.currentLocale()
            numberFormatter.maximumFractionDigits = 1
            if let format = numberFormatter.stringFromNumber(totalStepsReduced)
            {
                return String(format: "%@k", format)
            }
        }
        
        return "0"
    }
    
    
    class func refreshComplication()
    {
        let server = CLKComplicationServer.sharedInstance()
        if let allComplications = server.activeComplications
        {
            for complication in allComplications
            {
                server.reloadTimelineForComplication(complication)
            }
        }
    }
    
}
