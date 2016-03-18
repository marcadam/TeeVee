//
//  ChannelCollectionPagingViewCell.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/10/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol ChannelCollectionPagingViewCellDelegate: class {
    func channelCollectionPageView(sender: ChannelCollectionPagingViewCell, didPlayChannel channel: Channel)
}

class ChannelCollectionPagingViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    var featuredChannels: [Channel]! {
        didSet {
            let pageWidth = scrollView.bounds.width
            let pageHeight = scrollView.bounds.height
            let numberOfPages = featuredChannels.count
            pageControl.numberOfPages = numberOfPages
            scrollView.contentSize = CGSize(width: pageWidth * CGFloat(numberOfPages), height: pageHeight)

            for index in 0..<numberOfPages {
                let pageView = ChannelCollectionPageView(frame: CGRect(x: (pageWidth * CGFloat(index)), y: 0, width: pageWidth, height: pageHeight))
                pageView.delegate = self
                pageView.channel = featuredChannels[index]
                scrollView.addSubview(pageView)
            }
        }
    }

    weak var delegate: ChannelCollectionPagingViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        scrollView.delegate = self

        let scrollViewWidth = UIScreen.mainScreen().bounds.width
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: 200)
        scrollView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
    }

    @IBAction func pageControlDidPage(sender: UIPageControl) {
        let xOffset = scrollView.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPointMake(xOffset, 0) , animated: true)
    }
}

extension ChannelCollectionPagingViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
}

extension ChannelCollectionPagingViewCell: ChannelCollectionPageViewDelegate {
    func channelCollectionPageView(sender: ChannelCollectionPageView, didPlayChannel channel: Channel) {
        delegate?.channelCollectionPageView(self, didPlayChannel: channel)
    }
}
