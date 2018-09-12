//
//  LoaderInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 7/31/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import Foundation


class LoaderInterfaceController: WKInterfaceController
{
    override func awake(withContext context: Any?)
    {
        super.awake(withContext: context)
        
        WKInterfaceController.reloadRootControllers(withNames: ["mainInterfaceController", "weekInterfaceController"], contexts: nil)
    }
}
