//
//  HourGraphBarView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/15/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class HourGraphBarView: UIView
{
    var percent : CGFloat = 0.0
    {
        didSet
        {
            setNeedsDisplay()
        }
    }

    var color : UIColor = Globals.primaryColor()
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if (percent > 0.0)
        {
            let barHeight = CGFloat(floorf(Float(rect.height * percent)))
            let barRect = CGRect(x: 0, y: rect.height - barHeight, width: rect.width, height: barHeight)
            let bar = UIBezierPath(roundedRect: barRect, cornerRadius: 2.0)
            color.setFill()
            bar.fill()
        }
    }
}
