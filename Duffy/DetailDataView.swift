//
//  DetailDataView.swift
//  Duffy
//
//  Created by Patrick Rills on 8/13/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class DetailDataViewPageViewController : UIViewController
{
    func refresh() {}
    
    var margin = UIEdgeInsets.zero
    
    func setMargin(_ margin: UIEdgeInsets)
    {
        self.margin = margin
    }
}

class DetailDataView: UIView, UIScrollViewDelegate
{
    @IBOutlet weak var scrollView : UIScrollView?
    @IBOutlet weak var pageControl : UIPageControl?
    
    private var detailViewControllers = [DetailDataViewPageViewController]()
    
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
        
        if (!Globals.isNarrowPhone())
        {
            detailViewControllers.append(HourGraphDetailViewController.init(nibName: "HourGraphDetailViewController", bundle: Bundle.main))
        }
        
        detailViewControllers.append(DistanceFlightsDetailViewController.init(nibName: "DistanceFlightsDetailViewController", bundle: Bundle.main))
        
        for vc in detailViewControllers
        {
            scrollView?.addSubview(vc.view)
        }
        
        if let pager = pageControl
        {
            pager.isHidden = detailViewControllers.count == 1
            pager.currentPageIndicatorTintColor = Globals.primaryColor()
            pager.pageIndicatorTintColor = Globals.lightGrayColor()
            pager.numberOfPages = detailViewControllers.count
            pager.currentPage = 0
        }
    }
    
    func refresh()
    {
        for vc in detailViewControllers
        {
            vc.refresh()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let scroll = scrollView
        {
            let detailViewCount = detailViewControllers.count
            for i in 0..<detailViewCount
            {
                detailViewControllers[i].view.frame = CGRect(x: (CGFloat(i) * scroll.frame.size.width), y: 0, width: scroll.frame.size.width, height: scroll.frame.size.height)

                var bottomMargin : CGFloat = 0.0
                if let pager = pageControl, !pager.isHidden
                {
                    bottomMargin = scroll.frame.size.height - pager.frame.origin.y
                }
                detailViewControllers[i].setMargin(UIEdgeInsets.init(top: 0, left: 0, bottom: bottomMargin, right: 0))
            }
            scroll.contentSize = CGSize(width: CGFloat(detailViewCount) * scroll.frame.size.width, height: scroll.frame.size.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if let pager = pageControl, !pager.isHidden
        {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
            pager.currentPage = page
        }
    }
}
