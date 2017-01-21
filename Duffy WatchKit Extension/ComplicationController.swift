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
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void)
    {
        handler(.showOnLockScreen)
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void)
    {
        handler(CLKComplicationTimeTravelDirections())
    }
    
    func requestedUpdateDidBegin()
    {
        ComplicationController.refreshComplication()
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void))
    {
        // Call the handler with the current timeline entry
        var entry: CLKComplicationTimelineEntry?
        let steps = HealthCache.getStepsFromCache(Date())
        
        if (complication.family == .modularSmall)
        {
            entry = getEntryForModularSmall(NSNumber(value: steps as Int))
        }
        else if (complication.family == .modularLarge)
        {
            entry = getEntryForModularLarge(NSNumber(value: steps as Int))
        }
        else if (complication.family == .circularSmall)
        {
            entry = getEntryForCircularSmall(NSNumber(value: steps as Int))
        }
        else if (complication.family == .utilitarianLarge)
        {
            entry = getEntryForUtilitarianLarge(NSNumber(value: steps as Int))
        }
        else if (complication.family == .utilitarianSmall)
        {
            entry = getEntryForUtilitarianSmall(NSNumber(value: steps as Int))
        }
        
        handler(entry)
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void)
    {
        handler(Date(timeIntervalSinceNow: 60*30))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate?
        if (complication.family == .modularSmall)
        {
            template = getTemplateForModularSmall(NSNumber(value: 0 as Int))
        }
        else if (complication.family == .modularLarge)
        {
            template = getTemplateForModularLarge(NSNumber(value: 0 as Int))
        }
        else if (complication.family == .circularSmall)
        {
            template = getTemplateForCircularSmall(NSNumber(value: 0 as Int))
        }
        else if (complication.family == .utilitarianLarge)
        {
            template = getTemplateForUtilitarianLarge(NSNumber(value: 0 as Int))
        }
        else if (complication.family == .utilitarianSmall)
        {
            template = getTemplateForUtilitarianSmall(NSNumber(value: 0 as Int))
        }
        
        handler(template)
    }
    
    //MARK: - templates for various complication types
    
    func getEntryForModularSmall(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let small = getTemplateForModularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: small)
    }
    
    func getTemplateForModularSmall(_ totalSteps: NSNumber) -> CLKComplicationTemplateModularSmallStackText
    {
        let smallStack = CLKComplicationTemplateModularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = String(format: "%@", formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        line1.tintColor = UIColor.white
        smallStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 103.0/255.0, green: 171.0/255.0, blue: 229.0/255.0, alpha: 1)
        smallStack.line2TextProvider = line2
        
        return smallStack
    }
    
    func getEntryForModularLarge(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let large = getTemplateForModularLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForModularLarge(_ totalSteps: NSNumber) -> CLKComplicationTemplateModularLargeTallBody
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
        body.tintColor = UIColor.white
        tall.bodyTextProvider = body
        
        return tall
    }
    
    func getEntryForCircularSmall(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let circular = getTemplateForCircularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circular)
    }
    
    func getTemplateForCircularSmall(_ totalSteps: NSNumber) -> CLKComplicationTemplateCircularSmallStackText
    {
        let circularStack = CLKComplicationTemplateCircularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = String(format: "%@", formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        line1.tintColor = UIColor.white
        circularStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 103.0/255.0, green: 171.0/255.0, blue: 229.0/255.0, alpha: 1)
        circularStack.line2TextProvider = line2
        
        return circularStack
    }
    
    func getEntryForUtilitarianLarge(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let large = getTemplateForUtilitarianLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForUtilitarianLarge(_ totalSteps: NSNumber) -> CLKComplicationTemplateUtilitarianLargeFlat
    {
        let flat = CLKComplicationTemplateUtilitarianLargeFlat()
        let formattedStepsLong = formatStepsForLarge(totalSteps)
        let formattedStepsShort = formatStepsForSmall(totalSteps)
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: "%@ STEPS", formattedStepsLong)
        text.shortText = String(format: "%@ STEPS", formattedStepsShort)
        text.tintColor = UIColor.white
        flat.textProvider = text
        
        return flat
    }
    
    func getEntryForUtilitarianSmall(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let small = getTemplateForUtilitarianSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: small)
    }
    
    func getTemplateForUtilitarianSmall(_ totalSteps: NSNumber) -> CLKComplicationTemplateUtilitarianSmallFlat
    {
        let flat = CLKComplicationTemplateUtilitarianSmallFlat()
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: "%@", formatStepsForSmall(totalSteps))
        text.shortText = text.text
        text.tintColor = UIColor.white
        flat.textProvider = text
        
        return flat
    }
    
    func formatStepsForLarge(_ totalSteps: NSNumber) -> String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.locale = Locale.current
        if let format = numberFormatter.string(from: totalSteps)
        {
            return format
        }
        
        return "0"
    }
    
    func formatStepsForSmall(_ totalSteps: NSNumber) -> String
    {
        if (totalSteps.intValue >= 1000)
        {
            let totalStepsReduced = NSNumber(value: totalSteps.doubleValue / 1000.0 as Double)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = 1
            if let format = numberFormatter.string(from: totalStepsReduced)
            {
                return String(format: "%@k", format)
            }
        }
        else
        {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = 0
            if let format = numberFormatter.string(from: totalSteps)
            {
                return String(format: "%@", format)
            }
        }
        
        return "0"
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Swift.Void)
    {
        let sampleDisplaySteps = NSNumber(value: 12500 as Int)
        var template: CLKComplicationTemplate?
        if (complication.family == .modularSmall)
        {
            template = getTemplateForModularSmall(sampleDisplaySteps)
        }
        else if (complication.family == .modularLarge)
        {
            template = getTemplateForModularLarge(sampleDisplaySteps)
        }
        else if (complication.family == .circularSmall)
        {
            template = getTemplateForCircularSmall(sampleDisplaySteps)
        }
        else if (complication.family == .utilitarianLarge)
        {
            template = getTemplateForUtilitarianLarge(sampleDisplaySteps)
        }
        else if (complication.family == .utilitarianSmall)
        {
            template = getTemplateForUtilitarianSmall(sampleDisplaySteps)
        }
        
        handler(template)
    }
    
    
    class func refreshComplication()
    {
        let server = CLKComplicationServer.sharedInstance()
        if let allComplications = server.activeComplications
        {
            for complication in allComplications
            {
                server.reloadTimeline(for: complication)
            }
        }
    }
    
}
