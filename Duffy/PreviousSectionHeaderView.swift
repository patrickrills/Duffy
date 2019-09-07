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
        backgroundView?.backgroundColor = .clear
        
        headerLabel.text = "Previous Week"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        headerLabel.numberOfLines = 1
        
        actionLabel.text = "VIEW HISTORY"
        actionLabel.font = UIFont.systemFont(ofSize: 14.0)
        actionLabel.numberOfLines = 1
        actionLabel.textAlignment = .right
        
        button.addTarget(self, action: #selector(onTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(onTouchUp), for: .touchUpOutside)
        button.addTarget(self, action: #selector(onTouchUp), for: .touchCancel)
        
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
        actionLabel.frame = CGRect(x: frame.size.width - 15.0 - size.width, y: frame.size.height - size.height - 11.5, width: size.width, height: size.height)
        
        if #available(iOS 13.0, *) {
            headerLabel.textColor = .label
            actionLabel.textColor = Globals.secondaryColor()
        }
    }
    
    @IBAction func onTouchDown()
    {
        actionLabel.textColor = Globals.secondaryColor().withAlphaComponent(0.5)
    }
    
    @IBAction func onTouchUp()
    {
        actionLabel.textColor = Globals.secondaryColor()
    }
}
