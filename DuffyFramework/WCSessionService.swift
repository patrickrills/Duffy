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
    func complicationUpdateRequested(complicationData : [String : AnyObject])
}

public class WCSessionService : NSObject, WCSessionDelegate
{
    private static let instance: WCSessionService = WCSessionService()
    private var delegate: WCSessionServiceDelegate?
    
    override init()
    {
        super.init()
        
        if (WCSession.isSupported())
        {
            WCSession.defaultSession().delegate = self
            WCSession.defaultSession().activateSession()
        }
    }
    
    public class func getInstance() -> WCSessionService
    {
        return instance
    }
    
    public func initialize(withDelegate: WCSessionServiceDelegate)
    {
        delegate = withDelegate
    }
    
    public func updateWatchFaceComplication(complicationData : [String : AnyObject])
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
    
    private func sendComplicationDataToWatch(complicationData : [String : AnyObject])
    {
        #if os(iOS)
            if (WCSession.isSupported())
            {
                if (WCSession.defaultSession().activationState == .Activated
                    && WCSession.defaultSession().complicationEnabled)
                {
                    WCSession.defaultSession().transferCurrentComplicationUserInfo(complicationData)
                }
            }
        #endif
    }
    
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject])
    {
        for (key, value) in userInfo
        {
            if (key == "stepsdataresponse")
            {
                NSLog("Received steps from phone")
                
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
        }
    }
}
