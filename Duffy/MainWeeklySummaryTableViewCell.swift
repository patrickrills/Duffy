//
//  MainWeeklySummaryTableViewCell.swift
//  Duffy
//
//  Created by Patrick Rills on 4/18/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class MainWeeklySummaryTableViewCell: UITableViewCell {

    @IBOutlet private weak var averageLabel : UILabel!
    @IBOutlet private weak var progressLabel : UILabel!
    
    private lazy var verticalSeparator: ThinSeparator = {
        let vert = ThinSeparator(frame: CGRect(x: 0, y: 0, width: 72.0, height: 2.0))
        vert.transform = CGAffineTransform(rotationAngle: (90.0 * .pi) / 180.0)
        vert.backgroundColor = .clear
        return vert
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        isUserInteractionEnabled = false
        
        contentView.addSubview(verticalSeparator)
    }
    
    func bind(average: Steps, progress: Double) {
        var displayAverage = "??"
        let descriptionAverage = NSLocalizedString("Average", comment: "")
        var displayProgress = "??"
        let descriptionProgress = NSLocalizedString("From Prior Week", comment: "")
        var arrowProgress: NSAttributedString?
        var showProgress = true
        
        let valueFont = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        let descriptionFont = UIFont.systemFont(ofSize: 15.0, weight: .regular)
                
        let textColor: UIColor = .label
        let labelColor: UIColor = .secondaryLabel
        
        if let averageFormatted = Globals.stepsFormatter().string(for: average) {
            displayAverage = averageFormatted
        }
        
        if progress != .infinity {
            let roundedProgress = round(progress * 100.0)
            
            if progress > 0.0 && roundedProgress == 0 {
                displayProgress = "<1%"
            } else if let progressFormatted = Globals.percentFormatter().string(for: progress) {
                displayProgress = progressFormatted
            }
            
            arrowProgress = arrow(for: progress, in: textColor, with: valueFont)
        } else {
            showProgress = false
        }
        
        let attributedAverage = NSMutableAttributedString(string: String(format: "%@\n%@", displayAverage, descriptionAverage))
        attributedAverage.addAttributes([.font: valueFont, .foregroundColor : Globals.averageColor()], range: NSRange(location: 0, length: displayAverage.count))
        attributedAverage.addAttributes([.font: descriptionFont, .foregroundColor : labelColor], range: NSRange(location: attributedAverage.string.count - descriptionAverage.count, length: descriptionAverage.count))
        averageLabel.attributedText = attributedAverage
        
        if showProgress {
            let attributedProgress = NSMutableAttributedString(string: String(format: "%@\n%@", displayProgress, descriptionProgress))
            attributedProgress.addAttributes([.font: valueFont, .foregroundColor : textColor], range: NSRange(location: 0, length: displayProgress.count))
            attributedProgress.addAttributes([.font: descriptionFont, .foregroundColor : labelColor], range: NSRange(location: attributedProgress.string.count - descriptionProgress.count, length: descriptionProgress.count))
            if let arrowProgress = arrowProgress {
                attributedProgress.insert(arrowProgress, at: 0)
            }
            progressLabel.attributedText = attributedProgress
        }
        
        progressLabel.isHidden = !showProgress
        verticalSeparator.isHidden = progressLabel.isHidden
    }
    
    private func arrow(for value: Double, in color: UIColor, with font: UIFont) -> NSAttributedString? {
        guard value != 0.0 && value != .infinity else { return nil }
        
        let symbolConfiguration = UIImage.SymbolConfiguration(font: font)
        let symbolImage = UIImage(systemName: (value > 0 ? "arrow.up" : "arrow.down"), withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        let symbolTextAttachment = NSTextAttachment()
        symbolTextAttachment.image = symbolImage
        let attachmentString = NSMutableAttributedString(attachment: symbolTextAttachment)
        attachmentString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: attachmentString.string.count))
        attachmentString.append(NSAttributedString(string: " "))
        return attachmentString
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        verticalSeparator.frame = CGRect(x: CGFloat(floor(contentView.frame.midX)) - CGFloat(floor(verticalSeparator.frame.size.width / 2.0)),
                                         y: CGFloat(floor(contentView.frame.midY)) - CGFloat(floor(verticalSeparator.frame.size.height / 2.0)),
                                         width: verticalSeparator.frame.size.width,
                                         height: verticalSeparator.frame.size.height)
        
        subviews
            .filter {
                return String(describing: $0.self).contains("SeparatorView")
            }
            .forEach {
                $0.isHidden = true
        }
    }
}
