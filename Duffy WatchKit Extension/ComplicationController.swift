//
//  ComplicationController.swift
//  Duffy WatchKit Extension
//
//  Created by Patrick Rills on 6/28/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import ClockKit
import SwiftUI
import DuffyWatchFramework

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    private let IDENTIFIER_JUST_STEPS = "Duffy-Steps"
    private let IDENTIFIER_GAUGES = "Duffy-Gauges"
    
    @available(watchOSApplicationExtension 7.0, *)
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        handler([
            CLKComplicationDescriptor(identifier: IDENTIFIER_JUST_STEPS, displayName: "Duffy", supportedFamilies: CLKComplicationFamily.allCases),
            CLKComplicationDescriptor(identifier: IDENTIFIER_GAUGES, displayName: "Duffy (Gauge)", supportedFamilies: [.graphicCircular, .graphicRectangular, .graphicCorner])
        ])
    }
    
    // MARK: Timeline Configuration
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: Timeline Population
    
    class func refreshComplication() {
        let server = CLKComplicationServer.sharedInstance()
        if let allComplications = server.activeComplications {
            allComplications.forEach { server.reloadTimeline(for: $0) }
            let log = allComplications.count > 0 ? "Complication reloadTimeline" : "Complication reloadTimeline but no active found"
            LoggingService.log(log, with: String(format: "%d", HealthCache.lastSteps(for: Date())))
        } else {
            LoggingService.log("Complication reloadTimeline but no active found", at: .debug)
        }
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if let oneMinuteAfterMidnight = Date().nextDay().changeTime(hour: 0, minute: 1, second: 0) {
            handler(oneMinuteAfterMidnight)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let tomorrow = Date().nextDay()
                
        if date < tomorrow,
           let oneSecondAfterMidnight = tomorrow.changeTime(hour: 0, minute: 0, second: 1),
           let tomorrowsEntry = entry(for: complication, with: 0)
        {
            tomorrowsEntry.date = oneSecondAfterMidnight
            handler([tomorrowsEntry])
        } else {
            handler(nil)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        var steps: Steps = 0
        if !HealthCache.cacheIsForADifferentDay(than: Date()) {
            steps = HealthCache.lastSteps(for: Date())
        }
        
        LoggingService.log("Complication getCurrentTimelineEntry", with: String(format: "%d", steps))
        
        handler(entry(for: complication, with: steps))
    }
    
    private func entry(for complication: CLKComplication, with steps: Steps) -> CLKComplicationTimelineEntry? {
        var complicationId = ""
        if #available(watchOS 7.0, *) {
            complicationId = complication.identifier
        }
        
        switch complication.family {
        case .modularSmall:
            return getEntryForModularSmall(steps)
        case .modularLarge:
            return getEntryForModularLarge(steps)
        case .circularSmall:
            return getEntryForCircularSmall(steps)
        case .utilitarianLarge:
            return getEntryForUtilitarianLarge(steps)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return getEntryForUtilitarianSmall(steps)
        case .extraLarge:
            return getEntryForExtraLarge(steps)
        default:
            break
        }
        
        if #available(watchOS 5.0, *) {
            let stepsGoal = HealthCache.dailyGoal()
            switch complication.family {
            case .graphicRectangular:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        return getEntryForNoGaugeGraphicRectangle(steps)
                    }
                }
                
                return getEntryForGraphicRectangle(steps, stepsGoal)
            case .graphicCorner:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        return getEntryForNoGaugeGraphicCorner(steps)
                    }
                }
                
                return getEntryForGraphicCorner(steps, stepsGoal)
            case .graphicCircular:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        return getEntryForNoGaugeGraphicCircular(steps)
                    }
                }
                
                return getEntryForGraphicCircular(steps, stepsGoal)
            case .graphicBezel:
                return getEntryForGraphicBezel(steps, stepsGoal)
            default:
                break
            }
        }
        
        if #available(watchOS 7.0, *) {
            switch complication.family {
            case .graphicExtraLarge:
                return getEntryForGraphicExtraLarge(steps)
            default:
                break
            }
        }
        
        return nil
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Swift.Void) {
        let sampleSteps: Steps = 5000
        let sampleStepsGoal: Steps = 10000
        
        var template: CLKComplicationTemplate?
        
        switch complication.family {
        case .modularSmall:
            template = getTemplateForModularSmall(sampleSteps)
        case .modularLarge:
            template = getTemplateForModularLarge(sampleSteps)
        case .circularSmall:
            template = getTemplateForCircularSmall(sampleSteps)
        case .utilitarianLarge:
            template = getTemplateForUtilitarianLarge(sampleSteps)
        case .utilitarianSmall, .utilitarianSmallFlat:
            template = getTemplateForUtilitarianSmall(sampleSteps)
        case .extraLarge:
            template = getTemplateForExtraLarge(sampleSteps)
        default:
            break
        }
        
        var complicationId = ""
        if #available(watchOS 7.0, *) {
            complicationId = complication.identifier
        }
        
        if #available(watchOS 5.0, *) {
            switch complication.family {
            case .graphicRectangular:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        template = getTemplateForNoGaugeGraphicRectangle(sampleSteps)
                        break
                    }
                }
                
                template = getTemplateForGraphicRectangle(sampleSteps, sampleStepsGoal)
            case .graphicCorner:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        template = getTemplateForNoGaugeGraphicCorner(sampleSteps)
                        break
                    }
                }
                
                template = getTemplateForGraphicCorner(sampleSteps, sampleStepsGoal)
            case .graphicCircular:
                if #available(watchOSApplicationExtension 7.0, *) {
                    if complicationId == IDENTIFIER_JUST_STEPS {
                        template = getTemplateForNoGaugeGraphicCircular(sampleSteps)
                        break
                    }
                }
                
                template = getTemplateForTextCircular(sampleSteps, sampleStepsGoal)
            case .graphicBezel:
                template = getTemplateForGraphicBezel(sampleSteps, sampleStepsGoal)
            default:
                break
            }
        }
        
        if #available(watchOS 7.0, *) {
            switch complication.family {
            case .graphicExtraLarge:
                template = getTemplateForGraphicExtraLarge(sampleSteps)
            default:
                break
            }
        }
        
        handler(template)
    }
    
    //MARK: - Templates for various complication types
    
    //MARK: Colors
    
    private let BLUE_TINT = UIColor(red: 32.0/255.0, green: 148.0/255.0, blue: 250.0/255.0, alpha: 1)
    private let TEAL_TINT = UIColor(red: 45.0/255.0, green: 221.0/255.0, blue: 255.0/255.0, alpha: 1)
    
    //MARK: Modular Small
    
    func getEntryForModularSmall(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let small = getTemplateForModularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: small)
    }
    
    func getTemplateForModularSmall(_ totalSteps: Steps) -> CLKComplicationTemplateModularSmallStackText {
        let smallStack = CLKComplicationTemplateModularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = String(format: "%@", formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        line1.tintColor = .white
        smallStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        smallStack.line2TextProvider = line2
        
        return smallStack
    }
    
    //MARK: Modular Large
    
    func getEntryForModularLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let large = getTemplateForModularLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForModularLarge(_ totalSteps: Steps) -> CLKComplicationTemplateModularLargeTallBody {
        let tall = CLKComplicationTemplateModularLargeTallBody()
        
        let header = CLKSimpleTextProvider()
        header.text = NSLocalizedString("Steps", comment: "")
        header.shortText = header.text
        header.tintColor = BLUE_TINT
        tall.headerTextProvider = header
        
        let body = CLKSimpleTextProvider()
        body.text = formatStepsForLarge(totalSteps)
        body.shortText = body.text
        body.tintColor = .white
        tall.bodyTextProvider = body
        
        return tall
    }
    
    //MARK: Circular Small
    
    func getEntryForCircularSmall(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let circular = getTemplateForCircularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circular)
    }
    
    func getTemplateForCircularSmall(_ totalSteps: Steps) -> CLKComplicationTemplateCircularSmallStackText {
        let circularStack = CLKComplicationTemplateCircularSmallStackText()
        
        let line1 = CLKSimpleTextProvider()
        line1.text = formatStepsForSmall(totalSteps)
        line1.shortText = line1.text
        circularStack.line1TextProvider = line1
        
        let line2 = CLKSimpleTextProvider()
        line2.text =  NSLocalizedString("steps", comment: "")
        line2.shortText = line2.text
        circularStack.line2TextProvider = line2
        
        return circularStack
    }
    
    //MARK: Utilitarian Large
    
    func getEntryForUtilitarianLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let large = getTemplateForUtilitarianLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForUtilitarianLarge(_ totalSteps: Steps) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let flat = CLKComplicationTemplateUtilitarianLargeFlat()
        let formattedStepsLong = formatStepsForLarge(totalSteps)
        let formattedStepsShort = formatStepsForSmall(totalSteps)
        
        let text = CLKSimpleTextProvider()
        text.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsLong)
        text.shortText = String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsShort)
        
        flat.textProvider = text
        
        return flat
    }
    
    //MARK: Utilitarian Small
    
    func getEntryForUtilitarianSmall(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let small = getTemplateForUtilitarianSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: small)
    }
    
    func getTemplateForUtilitarianSmall(_ totalSteps: Steps) -> CLKComplicationTemplateUtilitarianSmallFlat {
        let flat = CLKComplicationTemplateUtilitarianSmallFlat()
        
        let text = CLKSimpleTextProvider()
        text.text = formatStepsForSmall(totalSteps)
        text.shortText = text.text
    
        flat.textProvider = text
        
        return flat
    }
    
    //MARK: Extra Large
    
    func getEntryForExtraLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let xLarge = getTemplateForExtraLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: xLarge)
    }
    
    func getTemplateForExtraLarge(_ totalSteps: Steps) -> CLKComplicationTemplate {
        let xLarge = CLKComplicationTemplateExtraLargeStackImage()
        
        xLarge.line1ImageProvider = CLKImageProvider(onePieceImage: RingDrawer.drawRing(totalSteps, goal: HealthCache.dailyGoal(), width: 120)!)
        xLarge.tintColor = TEAL_TINT
        
        let body = CLKSimpleTextProvider()
        body.text = formatStepsForLarge(totalSteps)
        body.shortText = formatStepsForSmall(totalSteps)
        xLarge.line2TextProvider = body
        
        return xLarge
    }
    
    //MARK: Graphic Extra Large
    
    @available(watchOSApplicationExtension 7.0, *)
    func getEntryForGraphicExtraLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let xLarge = getTemplateForGraphicExtraLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: xLarge)
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func getTemplateForGraphicExtraLarge(_ totalSteps: Steps) -> CLKComplicationTemplate {
        let xLarge = CLKComplicationTemplateGraphicExtraLargeCircularStackImage()
        
        xLarge.line1ImageProvider = CLKFullColorImageProvider(fullColorImage: RingDrawer.drawRing(totalSteps, goal: HealthCache.dailyGoal(), width: 36)!)
        xLarge.tintColor = TEAL_TINT
        
        let body = CLKSimpleTextProvider()
        body.text = formatStepsForLarge(totalSteps)
        body.shortText = formatStepsForSmall(totalSteps)
        xLarge.line2TextProvider = body
        
        return xLarge
    }
    
    //MARK: Graphic Corner
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForGraphicCorner(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
        let goalReached = totalSteps >= goal
        
        let stepsText = CLKSimpleTextProvider()
        stepsText.text = formatStepsForLarge(totalSteps)
        stepsText.shortText = formatStepsForSmall(totalSteps)
        
        if goalReached {
            let gcText = CLKComplicationTemplateGraphicCornerStackText()
            gcText.outerTextProvider = stepsText
            gcText.innerTextProvider = CLKSimpleTextProvider(text: NSLocalizedString("Goal achieved!", comment: ""))
            return gcText
        } else {
            let gcGauge = CLKComplicationTemplateGraphicCornerGaugeText()
            gcGauge.outerTextProvider = stepsText
            gcGauge.gaugeProvider = getGauge(for: totalSteps, goal: goal)
            gcGauge.trailingTextProvider = CLKSimpleTextProvider(text: formatStepsForVerySmall(goal))
            return gcGauge
        }
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForNoGaugeGraphicCorner(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForNoGaugeGraphicCorner(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForNoGaugeGraphicCorner(_ totalSteps: Steps) -> CLKComplicationTemplate {
        
        let stepsText = CLKSimpleTextProvider()
        stepsText.text = formatStepsForLarge(totalSteps)
        stepsText.shortText = formatStepsForSmall(totalSteps)
        
        let title = CLKSimpleTextProvider(text: NSLocalizedString("STEPS", comment: ""))
        title.tintColor = BLUE_TINT
        
        let gcText = CLKComplicationTemplateGraphicCornerStackText()
        gcText.outerTextProvider = stepsText
        gcText.innerTextProvider = title
        return gcText
    }
    
    //MARK: Graphic Circular
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForTextCircular(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForTextCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeText {
        let gc = CLKComplicationTemplateGraphicCircularClosedGaugeText()
        
        let text = CLKSimpleTextProvider()
        text.text = formatStepsForVerySmall(totalSteps)
        
        gc.centerTextProvider = text
        gc.gaugeProvider = getGauge(for: totalSteps, goal: goal)
        
        return gc
    }
    
    @available(watchOSApplicationExtension 6.0, *)
    func getEntryForNoGaugeGraphicCircular(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForNoGaugeGraphicCircular(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    @available(watchOSApplicationExtension 6.0, *)
    func getTemplateForNoGaugeGraphicCircular(_ totalSteps: Steps) -> CLKComplicationTemplateGraphicCircularStackText {
        let gc = CLKComplicationTemplateGraphicCircularStackText()
        
        let valueText = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps), shortText: formatStepsForSmall(totalSteps))
        gc.line1TextProvider = valueText
        
        let stepsText = CLKSimpleTextProvider(text: NSLocalizedString("steps", comment: ""))
        stepsText.tintColor = BLUE_TINT
        gc.line2TextProvider = stepsText
        
        return gc
    }
    
    //MARK: Graphic Bezel
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForGraphicBezel(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicBezelCircularText {
        let text = CLKSimpleTextProvider()
        text.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(totalSteps))
        text.tintColor = .white
        
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.circularTemplate = getTemplateForGraphicCircular(totalSteps, goal)
        template.textProvider = text
        return template
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func  getTemplateForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeImage {
        let gc = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
        let shoe = UIImage(named: "GraphicCircularShoe")!
        gc.imageProvider = CLKFullColorImageProvider.init(fullColorImage: shoe)
        gc.gaugeProvider = getGauge(for: totalSteps, goal: goal)
        return gc;
    }
    
    //MARK: Graphic Rectangle
    
    @available(watchOSApplicationExtension 5.0, *)
    func getEntryForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForGraphicRectangle(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    @available(watchOSApplicationExtension 5.0, *)
    func getTemplateForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
        let goalReached = totalSteps >= goal
        
        let shoe = UIImage(named: "GraphicRectShoe")!
        let image = CLKFullColorImageProvider(fullColorImage: shoe)
        
        let stepsText = CLKSimpleTextProvider()
        stepsText.text = String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(totalSteps))
        stepsText.tintColor = BLUE_TINT
    
        let progressText = CLKSimpleTextProvider()
        progressText.text = goalReached
                                ? Trophy.trophy(for: totalSteps).symbol() + " +" + formatStepsForSmall(totalSteps - goal)
                                : String(format: NSLocalizedString("%@ to go", comment: ""), formatStepsForSmall(goal - totalSteps))
        
        if goalReached {
            let textTemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            textTemplate.headerImageProvider = image
            textTemplate.headerTextProvider = stepsText
            textTemplate.body1TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("Goal achieved!", comment: ""))
            textTemplate.body2TextProvider = progressText
            return textTemplate
        } else {
            let gaugeTemplate = CLKComplicationTemplateGraphicRectangularTextGauge()
            gaugeTemplate.headerImageProvider = image
            gaugeTemplate.headerTextProvider = stepsText
            gaugeTemplate.body1TextProvider = progressText
            gaugeTemplate.gaugeProvider = getGauge(for: totalSteps, goal: goal)
            return gaugeTemplate
        }
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func getEntryForNoGaugeGraphicRectangle(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForNoGaugeGraphicRectangle(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func getTemplateForNoGaugeGraphicRectangle(_ totalSteps: Steps) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicRectangularFullView(
            GraphicRectangularFullView(shoeImage: UIImage(named: "GraphicRectShoe")!,
                                       title: NSLocalizedString("Steps", comment: ""),
                                       titleTintColor: BLUE_TINT,
                                       totalStepsFormatted: formatStepsForLarge(totalSteps)
                                      )
        )
        
    }
    
    //MARK: Gauge
    
    @available(watchOSApplicationExtension 5.0, *)
    func getGauge(for totalSteps: Steps, goal: Steps) -> CLKSimpleGaugeProvider {
        return CLKSimpleGaugeProvider(style: .fill, gaugeColor: BLUE_TINT, fillFraction: Float(min(totalSteps, goal)) / Float(goal))
    }
    
    //MARK: Number Formatters
    
    func formatStepsForLarge(_ totalSteps: Steps) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        if let format = numberFormatter.string(for: totalSteps) {
            return format
        }
        
        return "0"
    }
    
    private func formatStepsForSmall(_ totalSteps: Steps) -> String {
        let moreThan1000 = totalSteps >= 1000
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = moreThan1000 ? 1 : 0
        numberFormatter.roundingMode = moreThan1000 ? .down : .ceiling
        
        var displaySteps: Double = Double(totalSteps)
        var suffix = ""
        
        if moreThan1000 {
            displaySteps /= 1000.0
            suffix = "k"
        }
        
        if let format = numberFormatter.string(for: displaySteps) {
            return String(format: "%@%@", format, suffix)
        }
        
        return "0"
    }
    
    func formatStepsForVerySmall(_ totalSteps: Steps) -> String {
        if totalSteps >= 1000 {
            let displaySteps: Double = Double(totalSteps) / 1000.0
            let numberFormatter = NumberFormatter()
            numberFormatter.roundingMode = .down
            numberFormatter.numberStyle = .decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = totalSteps >= 10000 ? 0 : 1
            if let format = numberFormatter.string(for: displaySteps) {
                return format.count <= 2 ? String(format: "%@k", format) : format
            }
        }
        
        return totalSteps > 0 ? "<1k" : "0"
    }
}
