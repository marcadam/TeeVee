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
    @IBOutlet weak var channelName: UILabel!

    var channel: Channel! {
        didSet {
            channelName.text = channel.title
            if let thumbnail = channel.thumbnail_url {
                channelImageView.setImageWithURL(NSURL(string: thumbnail)!, placeholderImage: UIImage(named: "placeholder"))
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        channelImageView.image = UIImage(named: "placeholder")
        backgroundColor = UIColor.clearColor()
        channelName.textColor = Theme.Colors.HighlightColor.color
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
