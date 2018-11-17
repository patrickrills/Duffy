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
    var button = UIButton(type: .custom)
    var headerLabel = UILabel(frame: CGRect.zero)
    var actionLabel = UILabel(frame: CGRect.zero)
    
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
        
        headerLabel.text = "Previous Week"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        headerLabel.textColor = UIColor.black
        headerLabel.numberOfLines = 1
        
        actionLabel.text = "VIEW HISTORY"
        actionLabel.font = UIFont.systemFont(ofSize: 13.0)
        actionLabel.textColor = Globals.secondaryColor()
        actionLabel.numberOfLines = 1
        actionLabel.textAlignment = .right
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(actionLabel)
        contentView.addSubview(button)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        headerLabel.frame = CGRect(x: 16.0, y: 0, width: frame.size.width - 32.0, height: frame.size.height)
        button.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        actionLabel.sizeToFit()
        let size = actionLabel.frame.size
        actionLabel.frame = CGRect(x: frame.size.width - 16.0 - size.width, y: frame.size.height - size.height - 12.0, width: size.width, height: size.height)
    }
}
