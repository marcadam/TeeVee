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
    @IBOutlet weak var tweetBackgroundView: UIView!
    
    let clearColor = UIColor.clearColor()
    let regFontColor = Theme.Colors.HighlightColor.color
    
    var tweet: Tweet! {
        didSet {
            let avatarUrl = NSURL(string: tweet.user!.profileImageUrl!)
            AvatarImageView.setImageWithURL(avatarUrl!, placeholderImage: UIImage(named: "placeholder"))
            nameLabel.text = tweet.user!.name
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            tweetContentLabel.text = tweet.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = clearColor
        contentView.backgroundColor = clearColor
        tweetBackgroundView.backgroundColor = Theme.Colors.LightBackgroundColor.color
        nameLabel.textColor = Theme.Colors.HighlightLightColor.color
        usernameLabel.textColor = Theme.Colors.HighlightLightColor.color
        tweetContentLabel.textColor = regFontColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
