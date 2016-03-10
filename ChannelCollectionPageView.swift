//
//  ChannelCollectionPageView.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/10/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ChannelCollectionPageView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var channelNameContainerView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "ChannelCollectionPageView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)

        // custom initialization logic
        channelNameContainerView.layer.cornerRadius = 4.0
        channelNameContainerView.clipsToBounds = true
        channelNameContainerView.layer.borderColor = UIColor.whiteColor().CGColor
        channelNameContainerView.layer.borderWidth = 1.0

        pageImageView.image = UIImage(named: "placeholder")
        channelNameLabel.text = "Nature Channel"
    }

}
