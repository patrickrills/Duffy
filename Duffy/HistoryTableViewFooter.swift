//
//  HistoryTableViewFooter.swift
//  Duffy
//
//  Created by Patrick Rills on 8/11/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HistoryTableViewFooter: UIView
{
    @IBOutlet weak var loadMoreButton : UIButton?
    
    class func createView() -> HistoryTableViewFooter?
    {
        if let nibViews = Bundle.main.loadNibNamed("HistoryTableViewFooter", owner:nil, options:nil),
            let footer = nibViews[0] as? HistoryTableViewFooter
        {
            return footer
        }
        
        return nil
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        loadMoreButton?.setTitleColor(Globals.secondaryColor(), for: .normal)
    }
}
