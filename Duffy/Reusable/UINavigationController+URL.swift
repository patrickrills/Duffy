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
    
    func openURL(_ urlAsString: String, appendLanaguageParameter: Bool = false) {
        guard let url = URL(string: urlAsString) else { return }
        
        var finalURL: URL = url
        if appendLanaguageParameter {
            if #available(iOS 16.0, *) {
                finalURL.append(queryItems: [URLQueryItem(name: "language", value: NSLocale.current.languageCode?.lowercased() ?? "en")])
            }
        }
        
        present(SFSafariViewController(url: finalURL), animated: true, completion: nil)
    }
    
}
