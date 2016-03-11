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

    var channel: Channel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Theme.Colors.LightBackgroundColor.color
        infoContainerView.backgroundColor = Theme.Colors.BackgroundColor.color
        channelNameLabel.textColor = Theme.Colors.HighlightColor.color

        channelImageView.image = UIImage(named: "placeholder")
        channelNameLabel.text = "Nature Channel"
    }
}
