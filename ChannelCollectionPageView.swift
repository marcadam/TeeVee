//
//  ChannelCollectionPageView.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/10/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol ChannelCollectionPageViewDelegate: class {
    func channelCollectionPageView(sender: ChannelCollectionPageView, didPlayChannel channel: Channel)
}

class ChannelCollectionPageView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var pageImageView: UIImageView!
    @IBOutlet weak var channelNameContainerView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!

    var channel: Channel! {
        didSet {
            channelNameLabel.text = channel.title
            if let coverURL = channel.curated?.cover_url {
                let request = NSURLRequest(URL: NSURL(string: coverURL)!)
                pageImageView.setImageWithURLRequest(request, placeholderImage: UIImage(named: "placeholder"), success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                    self.pageImageView.image = image
                    self.pageImageView.layer.opacity = 0
                    UIView.transitionWithView(self.pageImageView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.pageImageView.layer.opacity = 1
                        }, completion: { (bool: Bool) -> Void in
                            //
                    })
                    }, failure: { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                        //
                })
            }
        }
    }

    weak var delegate: ChannelCollectionPageViewDelegate?

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
        pageImageView.backgroundColor = UIColor.clearColor()
        channelNameContainerView.layer.cornerRadius = 4.0
        channelNameContainerView.clipsToBounds = true
        channelNameContainerView.backgroundColor = Theme.Colors.DarkBackgroundColor.color.colorWithAlphaComponent(0.7)
        channelNameContainerView.layer.borderColor = Theme.Colors.LightBackgroundColor.color.CGColor
        channelNameContainerView.layer.borderWidth = 1.0
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color
    }
    @IBAction func onTapChannel(sender: UITapGestureRecognizer) {
        delegate?.channelCollectionPageView(self, didPlayChannel: channel)
    }
}
