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

        // Theming
        channelNameContainerView.layer.cornerRadius = 4.0
        channelNameContainerView.clipsToBounds = true
        channelNameContainerView.backgroundColor = Theme.Colors.DarkBackgroundColor.color.colorWithAlphaComponent(0.7)
        channelNameContainerView.layer.borderColor = Theme.Colors.LightBackgroundColor.color.CGColor
        channelNameContainerView.layer.borderWidth = 1.0
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color

        // custom initialization logic
        pageImageView.image = UIImage(named: "placeholder")
        channelNameLabel.text = "Nature Channel"
    }

}