//
//  LoaderInterfaceController.swift
//  Duffy
//
//  Created by Patrick Rills on 7/31/16.
//  Copyright © 2016 Big Blue Fly. All rights reserved.
//

import WatchKit
import Foundation


class LoaderInterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WKInterfaceController.reloadRootControllers(withNames: ["mainInterfaceController", "weekInterfaceController"], contexts: nil)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
