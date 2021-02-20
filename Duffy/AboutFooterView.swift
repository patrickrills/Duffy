//
//  AboutFooterView.swift
//  Duffy
//
//  Created by Patrick Rills on 2/19/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit

class AboutFooterView: ButtonFooterView {

    override var buttonAttributedText: NSAttributedString {
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
        
        return attributedText
    }

}
