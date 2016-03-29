//
//  EmptyChannelCollectionViewCell.swift
//  TeeVee
//
//  Created by Jerry on 3/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AFNetworking

class EmptyChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var channelTextLabel: UILabel!
    @IBOutlet weak var channelImageView: UIImageView!
    
    var channel: Channel? {
        didSet {
            if let channel = channel {
                channelTextLabel.text = channel.title
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
