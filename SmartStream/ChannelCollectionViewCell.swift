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
            if let thumbnailURL = channel.thumbnail_url {
                channelImageView.setImageWithURL(NSURL(string: thumbnailURL)!, placeholderImage: UIImage(named: "placeholder"))
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Theme.Colors.LightBackgroundColor.color
        infoContainerView.backgroundColor = Theme.Colors.BackgroundColor.color
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color
    }
}
