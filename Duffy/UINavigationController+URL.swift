//
//  UINavigationController+URL.swift
//  Duffy
//
//  Created by Patrick Rills on 2/28/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension UINavigationController {
    
    func openURL(_ urlAsString: String) {
        guard let url = URL(string: urlAsString) else { return }
        
        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    
}
