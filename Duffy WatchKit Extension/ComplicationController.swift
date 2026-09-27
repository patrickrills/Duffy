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
        
        let stepsGoal = HealthCache.dailyGoal()
        
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
        
        var complicationId = ""
        if #available(watchOS 7.0, *) {
            complicationId = complication.identifier
        }
        
        
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
        let line1 = CLKSimpleTextProvider(text: String(format: "%@", formatStepsForSmall(totalSteps)))
        line1.shortText = line1.text
        
        let line2 = CLKSimpleTextProvider(text: NSLocalizedString("steps", comment: ""))
        line2.shortText = line2.text
        
        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: line1, line2TextProvider: line2)
    }
    
    //MARK: Modular Large
    
    func getEntryForModularLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let large = getTemplateForModularLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForModularLarge(_ totalSteps: Steps) -> CLKComplicationTemplateModularLargeTallBody {
        let header = CLKSimpleTextProvider(text: NSLocalizedString("Steps", comment: ""))
        header.shortText = header.text
        header.tintColor = BLUE_TINT
        
        let body = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps))
        body.shortText = body.text
        body.tintColor = .white
        
        return CLKComplicationTemplateModularLargeTallBody(headerTextProvider: header, bodyTextProvider: body)
    }
    
    //MARK: Circular Small
    
    func getEntryForCircularSmall(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let circular = getTemplateForCircularSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circular)
    }
    
    func getTemplateForCircularSmall(_ totalSteps: Steps) -> CLKComplicationTemplateCircularSmallStackText {
        let line1 = CLKSimpleTextProvider(text: formatStepsForSmall(totalSteps))
        line1.shortText = line1.text
        
        let line2 = CLKSimpleTextProvider(text: NSLocalizedString("steps", comment: ""))
        line2.shortText = line2.text
        
        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: line1, line2TextProvider: line2)
    }
    
    //MARK: Utilitarian Large
    
    func getEntryForUtilitarianLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let large = getTemplateForUtilitarianLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: large)
    }
    
    func getTemplateForUtilitarianLarge(_ totalSteps: Steps) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let formattedStepsLong = formatStepsForLarge(totalSteps)
        let formattedStepsShort = formatStepsForSmall(totalSteps)
        
        let text = CLKSimpleTextProvider(text: String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsLong))
        text.shortText = String(format: NSLocalizedString("%@ STEPS", comment: ""), formattedStepsShort)
        
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: text)
    }
    
    //MARK: Utilitarian Small
    
    func getEntryForUtilitarianSmall(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let small = getTemplateForUtilitarianSmall(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: small)
    }
    
    func getTemplateForUtilitarianSmall(_ totalSteps: Steps) -> CLKComplicationTemplateUtilitarianSmallFlat {
        let text = CLKSimpleTextProvider(text: formatStepsForSmall(totalSteps))
        text.shortText = text.text
        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: text)
    }
    
    //MARK: Extra Large
    
    func getEntryForExtraLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let xLarge = getTemplateForExtraLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: xLarge)
    }
    
    func getTemplateForExtraLarge(_ totalSteps: Steps) -> CLKComplicationTemplate {
        let img = CLKImageProvider(onePieceImage: RingDrawer.drawRing(totalSteps, goal: HealthCache.dailyGoal(), width: 120)!)
        let body = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps))
        body.shortText = formatStepsForSmall(totalSteps)
        return CLKComplicationTemplateExtraLargeStackImage(line1ImageProvider: img, line2TextProvider: body)
    }
    
    //MARK: Graphic Extra Large
    
    func getEntryForGraphicExtraLarge(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let xLarge = getTemplateForGraphicExtraLarge(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: xLarge)
    }
    
    func getTemplateForGraphicExtraLarge(_ totalSteps: Steps) -> CLKComplicationTemplate {
        let img = CLKFullColorImageProvider(fullColorImage: RingDrawer.drawRing(totalSteps, goal: HealthCache.dailyGoal(), width: 36)!)
        let body = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps))
        body.shortText = formatStepsForSmall(totalSteps)
        return CLKComplicationTemplateGraphicExtraLargeCircularStackImage(line1ImageProvider: img, line2TextProvider: body)
    }
    
    //MARK: Graphic Corner
    
    func getEntryForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForGraphicCorner(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    func getTemplateForGraphicCorner(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
        let goalReached = totalSteps >= goal
        
        let stepsText = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps))
        stepsText.shortText = formatStepsForSmall(totalSteps)
        
        if goalReached {
            let inner = CLKSimpleTextProvider(text: NSLocalizedString("Goal achieved!", comment: ""))
            return CLKComplicationTemplateGraphicCornerStackText(innerTextProvider: inner, outerTextProvider: stepsText)
        } else {
            let gauge = getGauge(for: totalSteps, goal: goal)
            let trail = CLKSimpleTextProvider(text: formatStepsForVerySmall(goal))
            return CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gauge, leadingTextProvider: nil, trailingTextProvider: trail, outerTextProvider: stepsText)
        }
    }
    
    func getEntryForNoGaugeGraphicCorner(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForNoGaugeGraphicCorner(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    func getTemplateForNoGaugeGraphicCorner(_ totalSteps: Steps) -> CLKComplicationTemplate {
        let stepsText = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps))
        stepsText.shortText = formatStepsForSmall(totalSteps)
        
        let title = CLKSimpleTextProvider(text: NSLocalizedString("STEPS", comment: ""))
        title.tintColor = BLUE_TINT
        
        return CLKComplicationTemplateGraphicCornerStackText(innerTextProvider: title, outerTextProvider: stepsText)
    }
    
    //MARK: Graphic Circular
    
    func getEntryForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForTextCircular(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    func getTemplateForTextCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeText {
        let text = CLKSimpleTextProvider(text: formatStepsForVerySmall(totalSteps))
        text.shortText = text.text.replacingOccurrences(of: "k", with: "")
        
        return CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: getGauge(for: totalSteps, goal: goal), centerTextProvider: text)
    }
    
    func getEntryForNoGaugeGraphicCircular(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gc = getTemplateForNoGaugeGraphicCircular(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gc)
    }
    
    func getTemplateForNoGaugeGraphicCircular(_ totalSteps: Steps) -> CLKComplicationTemplateGraphicCircularStackText {
        let valueText = CLKSimpleTextProvider(text: formatStepsForLarge(totalSteps, useGroupingSeparator: totalSteps <= 10000), shortText: formatStepsForSmall(totalSteps))
        
        let stepsText = CLKSimpleTextProvider(text: NSLocalizedString("steps", comment: ""))
        stepsText.tintColor = BLUE_TINT
        
        return CLKComplicationTemplateGraphicCircularStackText(line1TextProvider: valueText, line2TextProvider: stepsText)
    }
    
    //MARK: Graphic Bezel
    
    func getEntryForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForGraphicBezel(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    func getTemplateForGraphicBezel(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicBezelCircularText {
        let text = CLKSimpleTextProvider(text: String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(totalSteps)))
        text.tintColor = .white
        
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: getTemplateForGraphicCircular(totalSteps, goal), textProvider: text)
    }
    
    func  getTemplateForGraphicCircular(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplateGraphicCircularClosedGaugeImage {
        let shoe = UIImage(named: "GraphicCircularShoe")!
        return CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: getGauge(for: totalSteps, goal: goal), imageProvider: CLKFullColorImageProvider.init(fullColorImage: shoe))
    }
    
    //MARK: Graphic Rectangle
    
    func getEntryForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForGraphicRectangle(totalSteps, goal)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
    func getTemplateForGraphicRectangle(_ totalSteps: Steps, _ goal: Steps) -> CLKComplicationTemplate {
        let goalReached = totalSteps >= goal
        
        let shoe = UIImage(named: "GraphicRectShoe")!
        let image = CLKFullColorImageProvider(fullColorImage: shoe)
        
        let stepsText = CLKSimpleTextProvider(text: String(format: NSLocalizedString("%@ STEPS", comment: ""), formatStepsForLarge(totalSteps)))
        stepsText.tintColor = BLUE_TINT
    
        let text = goalReached
                        ? Trophy.trophy(for: totalSteps).symbol() + " +" + formatStepsForSmall(totalSteps - goal)
                        : String(format: NSLocalizedString("%@ to go", comment: ""), formatStepsForSmall(goal - totalSteps))
        let progressText = CLKSimpleTextProvider(text: text)
        
        if goalReached {
            return CLKComplicationTemplateGraphicRectangularStandardBody(headerImageProvider: image, headerTextProvider: stepsText, body1TextProvider: CLKSimpleTextProvider(text: NSLocalizedString("Goal achieved!", comment: "")), body2TextProvider: progressText)
        } else {
            return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: image, headerTextProvider: stepsText, body1TextProvider: progressText, gaugeProvider: getGauge(for: totalSteps, goal: goal))
        }
    }
    
    func getEntryForNoGaugeGraphicRectangle(_ totalSteps: Steps) -> CLKComplicationTimelineEntry {
        let gb = getTemplateForNoGaugeGraphicRectangle(totalSteps)
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: gb)
    }
    
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
    
    func getGauge(for totalSteps: Steps, goal: Steps) -> CLKSimpleGaugeProvider {
        return CLKSimpleGaugeProvider(style: .fill, gaugeColor: BLUE_TINT, fillFraction: Float(min(totalSteps, goal)) / Float(goal))
    }
    
    //MARK: Number Formatters
    
    func formatStepsForLarge(_ totalSteps: Steps, useGroupingSeparator: Bool = true) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.usesGroupingSeparator = useGroupingSeparator
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
