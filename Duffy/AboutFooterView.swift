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
    @IBOutlet weak var aboutButton : UIButton!
    
    var separatorIsVisible : Bool = true
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        aboutButton.setTitleColor(Globals.secondaryColor(), for: .normal)
        aboutButton.setTitleColor(Globals.secondaryColor().withAlphaComponent(0.4), for: .highlighted)
        aboutButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        
        let attributedText = NSMutableAttributedString()
        
        if #available(iOS 13.0, *) {
            let symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .body))
            let symbolImage = UIImage(systemName: "info.circle.fill", withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
            let symbolTextAttachment = NSTextAttachment()
            symbolTextAttachment.image = symbolImage
            let attachmentString = NSMutableAttributedString(attachment: symbolTextAttachment)
            attributedText.append(attachmentString)
            attributedText.append(NSAttributedString(string: " "))
        }
        
        attributedText.append(NSAttributedString(string: NSLocalizedString("About Duffy", comment: "")))
        
        aboutButton.setAttributedTitle(attributedText, for: .normal)
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
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if (separatorIsVisible)
        {
            let separator = UIBezierPath(rect: CGRect(x: 0, y: 1, width: rect.width, height: 0.33))
            Globals.separatorColor().setFill()
            separator.fill()
        }
    }
}
