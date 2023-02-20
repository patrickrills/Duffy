//
//  AppRater.swift
//  Duffy
//
//  Created by Patrick Rills on 9/16/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import StoreKit

class AppRater: NSObject
{
    private static let hasAskedKey = "hasAskedToRate"
    
    open class func askToRate()
    {
        guard !haveAsked(),
            let scene = UIApplication.shared.delegate?.window??.windowScene
        else {
            return
        }
        
        UserDefaults.standard.set(1, forKey: hasAskedKey)
        SKStoreReviewController.requestReview(in: scene)
    }
    
    open class func haveAsked() -> Bool
    {
        return UserDefaults.standard.integer(forKey: hasAskedKey) == 1
    }
    
    open class func redirectToAppStore()
    {
        guard let writeReviewURL = URL(string: "https://itunes.apple.com/us/app/duffy/id1207581673?action=write-review")
            else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
