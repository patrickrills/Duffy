//
//  AboutFooterView.swift
//  Duffy
//
//  Created by Patrick Rills on 11/10/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class AboutFooterView: UIView
{
    @IBOutlet weak var aboutButton : UIButton?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        aboutButton?.setTitleColor(Globals.secondaryColor(), for: .normal)
        aboutButton?.setTitleColor(Globals.secondaryColor().withAlphaComponent(0.4), for: .highlighted)
    }
    
    class func createView() -> AboutFooterView?
    {
        if let nibViews = Bundle.main.loadNibNamed("AboutFooterView", owner:nil, options:nil),
            let footer = nibViews[0] as? AboutFooterView
        {
            return footer
        }
        
        return nil
    }
}
