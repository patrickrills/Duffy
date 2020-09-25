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
        handler(.forward)
    }
    
    // MARK: - Timeline Population
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void)
    {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            handler(nil)
            return
        }
        
        var components = Calendar.current.dateComponents([.era, .year, .month, .day], from: tomorrow)
        components.hour = 0
        components.minute = 1
        components.second = 0
        components.timeZone = TimeZone.current
        
        if let oneMinuteAfterMidnight = Calendar.current.date(from: components) {
            handler(oneMinuteAfterMidnight)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void)
    {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            handler(nil)
            return
        }
        
        var components = Calendar.current.dateComponents([.era, .year, .month, .day], from: tomorrow)
        components.hour = 0
        components.minute = 0
        components.second = 1
        components.timeZone = TimeZone.current
        
        if date < tomorrow,
            let oneSecondAfterMidnight = Calendar.current.date(from: components),
            let tomorrowsEntry = entry(for: complication, with: 0) {
            tomorrowsEntry.date = oneSecondAfterMidnight
            handler([tomorrowsEntry])
        } else {
            handler(nil)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void))
    {
        // Call the handler with the current timeline entry
        var steps: Steps = 0
        if (!HealthCache.cacheIsForADifferentDay(Date())) {
            steps = Steps(HealthCache.getStepsFromCache(Date())) //TODO: remove cast
        }
        
        LoggingService.log("Complication getCurrentTimelineEntry", with: String(format: "%d", HealthCache.getStepsFromCache(Date())))
        
        handler(entry(for: complication, with: steps))
    }
    
    private func entry(for complication: CLKComplication, with steps: Steps) -> CLKComplicationTimelineEntry?
    {
        var entry: CLKComplicationTimelineEntry?
        
        if (complication.family == .modularSmall)
        {
            entry = getEntryForModularSmall(NSNumber(value: steps))
        }
        else if (complication.family == .modularLarge)
        {
            entry = getEntryForModularLarge(NSNumber(value: steps))
        }
        else if (complication.family == .circularSmall)
        {
            entry = getEntryForCircularSmall(NSNumber(value: steps))
        }
        else if (complication.family == .utilitarianLarge)
        {
            entry = getEntryForUtilitarianLarge(NSNumber(value: steps))
        }
        else if (complication.family == .utilitarianSmall || complication.family == .utilitarianSmallFlat)
        {
            entry = getEntryForUtilitarianSmall(NSNumber(value: steps))
        }
        else if (complication.family == .extraLarge)
        {
            entry = getEntryForExtraLarge(NSNumber(value: steps))
        }
        
        if #available(watchOS 5.0, *)
        {
            let stepsGoal = HealthCache.dailyGoal()
            
            if (complication.family == .graphicCorner)
            {
                entry = getEntryForGraphicCorner(steps, stepsGoal)
            }
            else if (complication.family == .graphicCircular)
            {
                entry = getEntryForGraphicCircular(steps, stepsGoal)
            }
            else if (complication.family == .graphicBezel)
            {
                entry = getEntryForGraphicBezel(steps, stepsGoal)
            }
            else if (complication.family == .graphicRectangular)
            {
                entry = getEntryForGraphicRectangle(steps, stepsGoal)
            }
        }
        
        return entry
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
        else if (complication.family == .utilitarianSmall || complication.family == .utilitarianSmallFlat)
        {
            template = getTemplateForUtilitarianSmall(NSNumber(value: 0 as Int))
        }
        else if (complication.family == .extraLarge)
        {
            template = getTemplateForExtraLarge(NSNumber(value: 0 as Int))
        }
        
        if #available(watchOS 5.0, *)
        {
            if (complication.family == .graphicCorner)
            {
                template = getTemplateForGraphicCorner(0, 10000)
            }
            else if (complication.family == .graphicCircular)
            {
                template = getTemplateForGraphicCircular(0, 10000)
            }
            else if (complication.family == .graphicBezel)
            {
                template = getTemplateForGraphicBezel(0, 10000)
            }
            else if (complication.family == .graphicRectangular)
            {
                template = getTemplateForGraphicRectangle(0, 10000)
            }
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
        line1.tintColor = .white
        smallStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1)
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
        header.tintColor = UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1)
        tall.headerTextProvider = header
        
        let body = CLKSimpleTextProvider()
        body.text = String(format: "%@", formatStepsForLarge(totalSteps))
        body.shortText = body.text
        body.tintColor = .white
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
        line1.tintColor = .white
        circularStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        line2.tintColor = UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1)
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
        text.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsLong)
        text.shortText = String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsShort)
        text.tintColor = .white
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
        text.tintColor = .white
        flat.textProvider = text
        
        return flat
    }
    
    func getEntryForExtraLarge(_ totalSteps: NSNumber) -> CLKComplicationTimelineEntry
    {
        let xLarge = getTemplateForExtraLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: xLarge)
    }
    
    func getTemplateForExtraLarge(_ totalSteps: NSNumber) -> CLKComplicationTemplateExtraLargeStackText
    {
        let xLarge = CLKComplicationTemplateExtraLargeStackText()

        let header = CLKSimpleTextProvider()
        header.text = NSLocalizedString("Steps", comment: "")
        header.shortText = header.text
        header.tintColor = UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1)
        xLarge.line1TextProvider = header
        
        let body = CLKSimpleTextProvider()
        body.text = String(format: "%@", formatStepsForLarge(totalSteps))
        body.shortText = body.text
        body.tintColor = .white
        xLarge.line2TextProvider = body
        
        return xLarge
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry
    {
        let gc = getTemplateForGraphicCorner(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCornerGaugeText
    {
        let gc = CLKComplicationTemplateGraphicCornerGaugeText()
        
        let text = CLKSimpleTextProvider()
        text.text = formatStepsForLarge(NSNumber(value: totalSteps))
        text.shortText = formatStepsForSmall(NSNumber(value: totalSteps))
        text.tintColor = .white
        
        let provider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1), fillFraction: Float(min(totalSteps, goal)) / Float(goal))
        
        gc.outerTextProvider = text
        gc.gaugeProvider = provider
        
        return gc;
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry
    {
        let gc = getTemplateForTextCircular(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func  getTemplateForTextCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeText
    {
        let gc = CLKComplicationTemplateGraphicCircularClosedGaugeText()
        
        let text = CLKSimpleTextProvider()
        text.text = formatStepsForVerySmall(NSNumber(value: totalSteps))
        text.tintColor = .white
        
        gc.centerTextProvider = text
        gc.gaugeProvider = getGauge(for: totalSteps, goal: goal)
        
        return gc;
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func  getTemplateForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeImage
    {
        let gc = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
        let shoe = UIImage(named: "GraphicCircularShoe")!
        gc.imageProvider = CLKFullColorImageProvider.init(fullColorImage: shoe)
        gc.gaugeProvider = getGauge(for: totalSteps, goal: goal)
        return gc;
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry
    {
        let gb = getTemplateForGraphicBezel(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicBezelCircularText
    {
        let text = CLKSimpleTextProvider()
        text.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(NSNumber(value: totalSteps)))
        text.tintColor = .white
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.circularTemplate = getTemplateForGraphicCircular(totalSteps, goal)
        template.textProvider = text
        return template
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry
    {
        let gb = getTemplateForGraphicRectangle(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicRectangularTextGauge
    {
        let shoe = UIImage(named: "GraphicRectShoe")!
        let image = CLKFullColorImageProvider(fullColorImage: shoe)
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(NSNumber(value: totalSteps)))
        text.tintColor = UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1)
        
        let toGoText = CLKSimpleTextProvider()
        if (totalSteps >= goal)
        {
            toGoText.text = NSLocalizedString("Goal achieved!", comment: "")
        }
        else
        {
            let toGo = goal - totalSteps
            toGoText.text = String(format: NSLocalizedString("%@ to go", comment: ""), formatStepsForSmall(NSNumber(value: toGo)))
        }
        
        let template = CLKComplicationTemplateGraphicRectangularTextGauge()
        template.headerImageProvider = image
        template.headerTextProvider = text
        template.body1TextProvider = toGoText
        template.gaugeProvider = getGauge(for: totalSteps, goal: goal)
        return template
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getGauge(for totalSteps: Steps, goal: Steps) -> CLKSimpleGaugeProvider
    {
        return CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor(red: 81.0/255.0, green: 153.0/255.0, blue: 238.0/255.0, alpha: 1), fillFraction: Float(min(totalSteps, goal)) / Float(goal))
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
    
    func formatStepsForVerySmall(_ totalSteps: NSNumber) -> String
    {
        if (totalSteps.intValue >= 1000)
        {
            let totalStepsReduced = NSNumber(value: totalSteps.doubleValue / Double(1000))
            let numberFormatter = NumberFormatter()
            numberFormatter.roundingMode = .floor
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = totalSteps.intValue >= 10000 ? 0 : 1
            if let format = numberFormatter.string(from: totalStepsReduced)
            {
                return format.count <= 2 ? String(format: "%@k", format) : format
            }
        }
        
        return totalSteps.intValue > 0 ? "<1k" : "0"
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
        else if (complication.family == .utilitarianSmall || complication.family == .utilitarianSmallFlat)
        {
            template = getTemplateForUtilitarianSmall(sampleDisplaySteps)
        }
        else if (complication.family == .extraLarge)
        {
            template = getTemplateForExtraLarge(sampleDisplaySteps)
        }
        
        if #available(watchOS 5.0, *)
        {
            let sampleStepsGoal: Steps = 10000
            
            if (complication.family == .graphicCorner)
            {
                template = getTemplateForGraphicCorner(12500, sampleStepsGoal)
            }
            else if (complication.family == .graphicCircular)
            {
                template = getTemplateForGraphicCircular(12500, sampleStepsGoal)
            }
            else if (complication.family == .graphicBezel)
            {
                template = getTemplateForGraphicBezel(12500, sampleStepsGoal)
            }
            else if (complication.family == .graphicRectangular)
            {
                template = getTemplateForGraphicRectangle(12500, sampleStepsGoal)
            }
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
            
            let log = allComplications.count > 0 ? "Complication reloadTimeline" : "Complication reloadTimeline but no active found"
            LoggingService.log(log, with: String(format: "%d", HealthCache.getStepsFromCache(Date())))
        }
        else
        {
            LoggingService.log("Complication reloadTimeline but no active found", at: .debug)
        }
    }
    
}
