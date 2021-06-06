//
//  AboutTableViewFooter.swift
//  Duffy
//
//  Created by Patrick Rills on 9/3/19.
//  Copyright © 2019 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class AboutTableViewFooter: UITableViewHeaderFooterView {
    
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var debugButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let version = String(format: NSLocalizedString("Version: %@", comment: ""), Globals.appVersion())
        let privacy = NSLocalizedString("Privacy Policy", comment: "")
        let combined = String(format: "%@ · %@", version, privacy)
        let attributed = NSMutableAttributedString(string: combined)
        
        attributed.addAttribute(.foregroundColor, value: UIColor.darkGray, range: NSRange(location: 0, length: combined.count - privacy.count - 1))
        attributed.addAttribute(.foregroundColor, value: Globals.secondaryColor(), range: NSRange(location: combined.count - privacy.count, length: privacy.count))
        aboutButton.setTitleColor(.lightGray, for: .normal)
        aboutButton.setAttributedTitle(attributed, for: .normal)
        
        debugButton.isHidden = !DebugService.isDebugModeEnabled()
    }
}
