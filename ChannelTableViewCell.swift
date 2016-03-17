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
    @IBOutlet weak var channelCreatedByLabel: UILabel!
    
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
            channelCreatedByLabel.text = "Created by Unknown"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        channelImageView.image = UIImage(named: "placeholder")
        backgroundColor = UIColor.clearColor()
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color
        channelCreatedByLabel.textColor = Theme.Colors.HighlightLightColor.color
        channelImageView.layer.cornerRadius = 6.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
