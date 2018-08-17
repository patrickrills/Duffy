//
//  DetailDataView.swift
//  Duffy
//
//  Created by Patrick Rills on 8/13/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class DetailDataView: UIView
{
    @IBOutlet weak var scrollView : UIScrollView?
    @IBOutlet weak var pageControl : UIPageControl?
    
    let distanceFlightController = DistanceFlightsDetailViewController.init(nibName: "DistanceFlightsDetailViewController", bundle: Bundle.main)
    
    class func createView() -> DetailDataView?
    {
        if let nibViews = Bundle.main.loadNibNamed("DetailDataView", owner:nil, options:nil),
            let detail = nibViews[0] as? DetailDataView
        {
            return detail
        }
        
        return nil
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        pageControl?.isHidden = true
//        pageControl?.currentPageIndicatorTintColor = Globals.primaryColor()
//        pageControl?.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
        scrollView?.addSubview(distanceFlightController.view)
    }
    
    func refresh()
    {
        distanceFlightController.refresh()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let scroll = scrollView
        {
            distanceFlightController.view.frame = CGRect(x: 0, y: 0, width: scroll.frame.size.width, height: scroll.frame.size.height)
        }
    }
}
