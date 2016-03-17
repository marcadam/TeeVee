//
//  ChannelCollectionViewCell
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!

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
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Theme.Colors.LightBackgroundColor.color
        infoContainerView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color
    }
}
