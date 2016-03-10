//
//  ChannelCollectionPagingViewCell.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/10/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ChannelCollectionPagingViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let scrollViewWidth = UIScreen.mainScreen().bounds.width
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: 200)

        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height
        scrollView.contentSize = CGSize(width: pageWidth * 3, height: pageHeight)

        for index in 0..<3 {
            let pageView = ChannelCollectionPageView(frame: CGRect(x: (pageWidth * CGFloat(index)), y: 0, width: pageWidth, height: pageHeight))
            scrollView.addSubview(pageView)
        }
    }
}
