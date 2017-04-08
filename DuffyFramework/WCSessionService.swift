//
//  WCSessionService.swift
//  Duffy
//
//  Created by Patrick Rills on 7/9/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import Foundation
import WatchConnectivity

public protocol WCSessionServiceDelegate
{
    func complicationUpdateRequested(_ complicationData : [String : AnyObject])
}

open class WCSessionService : NSObject, WCSessionDelegate
{
    #if os(iOS)
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
        
    
   }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    #endif
   
   /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    fileprivate static let instance: WCSessionService = WCSessionService()
    fileprivate var delegate: WCSessionServiceDelegate?
    
    override init()
    {
        super.init()
        
        if (WCSession.isSupported())
        {
            WCSession.default().delegate = self
            WCSession.default().activate()
        }
    }
    
    open class func getInstance() -> WCSessionService
    {
        return instance
    }
    
    open func initialize(_ withDelegate: WCSessionServiceDelegate)
    {
        delegate = withDelegate
    }
    
    open func updateWatchFaceComplication(_ complicationData : [String : AnyObject])
    {
        #if os(iOS)
            sendComplicationDataToWatch(complicationData)
        #else
            if let del = delegate
            {
                del.complicationUpdateRequested(complicationData)
            }
        #endif
    }
    
    fileprivate func sendComplicationDataToWatch(_ complicationData : [String : AnyObject])
    {
        #if os(iOS)
            if (WCSession.isSupported())
            {
                if (WCSession.default().activationState == .activated
                    && WCSession.default().isComplicationEnabled)
                {
                    WCSession.default().transferCurrentComplicationUserInfo(complicationData)
                }
            }
        #endif
    }
    
    open func notifyOtherDeviceOfGoalNotificaton()
    {
        if WCSession.isSupported()
        {
            if WCSession.default().activationState == .activated
            {
                WCSession.default().transferUserInfo(["goalNotificationSent" : NotificationService.convertDayToKey(Date()) as AnyObject])
            }
        }
    }
    
    open func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any])
    {
        for (key, value) in userInfo
        {
            if (key == "stepsdataresponse")
            {
                //NSLog("Received steps from phone")
                
                if let dict = value as? [String: AnyObject]
                {
                    if (HealthCache.saveStepsDataToCache(dict))
                    {
                        if let del = delegate
                        {
                            del.complicationUpdateRequested(dict)
                        }
                    }
                }
            }
            else if (key == "goalNotificationSent")
            {
                NSLog("goalNotificationSent was transferred")
                
                if let dayKey = value as? String
                {
                    NotificationService.markNotificationSentByOtherDevice(forKey: dayKey)
                }
            }
            /*else if (key == "stepsdailygoal")
            {
                NSLog("Goal was transferred")
                
                if let goalVal = value as? Int
                {
                    HealthCache.saveStepsGoalToCache(goalVal)
                }
            }*/
        }
    }
}
