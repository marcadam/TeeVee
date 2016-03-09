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

    var channel: Channel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        channelImageView.image = UIImage(named: "placeholder")
        channelName.text = "Nature Channel"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}