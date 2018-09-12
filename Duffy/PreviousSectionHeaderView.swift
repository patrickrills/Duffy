//
//  MainSectionHeaderView.swift
//  Duffy
//
//  Created by Patrick Rills on 7/14/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class PreviousSectionHeaderView: UITableViewHeaderFooterView
{
    var button : PastWeekButton?
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
     
        buildView()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        buildView()
    }
    
    func buildView()
    {
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor.white
        
        button = PastWeekButton()
        addSubview(button!)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let b = button
        {
            b.frame = CGRect(x: 8.0, y: 0, width: frame.size.width - 16.0, height: frame.size.height)
        }
    }
}
