//
//  HourGraphMaxIndicatorView.swift
//  Duffy
//
//  Created by Patrick Rills on 9/16/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class HourGraphMaxIndicatorView: UIView
{
    private weak var maxLabel : UILabel?
    var max : UInt = 0
    {
        didSet
        {
            displayMax()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize()
    {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        lbl.textColor = Globals.veryLightGrayColor()
        addSubview(lbl)
        maxLabel = lbl
    }
    
    private func displayMax()
    {
        if let lbl = maxLabel
        {
            lbl.text = Globals.stepsFormatter().string(from: NSNumber(value: max))
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let lbl = maxLabel
        {
            let textSize = lbl.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.frame.size.height))
            lbl.frame = CGRect(x: 0, y: 0, width: textSize.width, height: self.frame.size.height)
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if max > 0, let lbl = maxLabel, Constants.showGraphMaxLine
        {
            let lineY = rect.size.height / 2.0
            let dotted = UIBezierPath()
            dotted.move(to: CGPoint(x: lbl.frame.size.width + 4.0, y: lineY))
            dotted.addLine(to: CGPoint(x: rect.size.width, y: lineY))
            dotted.lineWidth = 1.0
            dotted.setLineDash([2.0, 2.0], count: 2, phase: 0.0)
            lbl.textColor.setStroke()
            dotted.stroke()
        }
    }
}
