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
                channelImageView.setImageWithURL(NSURL(string: thumbnail)!, placeholderImage: UIImage(named: "placeholder"))
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
