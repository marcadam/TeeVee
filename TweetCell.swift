//
//  TweetCell.swift
//  SmartStream
//
//  Created by Jerry on 3/16/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
