//
//  ChannelTableViewCell.swift
//  SmartChannel
//
//  Created by Marc Anderson on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelTopicsLabel: UILabel!
    
    var channel: Channel! {
        didSet {
            channelNameLabel.text = channel.title
            if let thumbnail = channel.thumbnail_url {
                let request = NSURLRequest(URL: NSURL(string: thumbnail)!)
                channelImageView.setImageWithURLRequest(request, placeholderImage: UIImage(named: "placeholder"), success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                    self.channelImageView.image = image
                    self.channelImageView.layer.opacity = 0
                    UIView.transitionWithView(self.channelImageView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.channelImageView.layer.opacity = 1
                        }, completion: { (bool: Bool) -> Void in
                            //
                    })
                    }, failure: { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                        //
                })
            }

            if let topics = channel.topics where topics.count > 0 {
                channelTopicsLabel.text = topics.joinWithSeparator(", ")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        channelImageView.image = UIImage(named: "placeholder")
        backgroundColor = UIColor.clearColor()
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color
        channelTopicsLabel.textColor = Theme.Colors.HighlightLightColor.color
        channelImageView.layer.cornerRadius = 6.0
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.contentView.backgroundColor = Theme.Colors.LightBackgroundColor.color
            })
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.contentView.backgroundColor = UIColor.clearColor()
            })
        }
    }
    
}
