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
    @IBOutlet weak var tweetDateLabel: UILabel!
    
    let clearColor = UIColor.clearColor()
    let regFontColor = Theme.Colors.HighlightColor.color
    
    var tweet: Tweet! {
        didSet {
            let avatarUrl = NSURL(string: tweet.user!.profileImageUrl!)
            AvatarImageView.setImageWithURL(avatarUrl!, placeholderImage: UIImage(named: "placeholder"))
            nameLabel.text = tweet.user!.name
            usernameLabel.text = "@\(tweet.user!.screenname!)"
            tweetContentLabel.text = tweet.text
            tweetDateLabel.text = tweet.formattedDateString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = clearColor
        contentView.backgroundColor = clearColor
        tweetBackgroundView.backgroundColor = Theme.Colors.LightBackgroundColor.color
        tweetBackgroundView.layer.opacity = 0.6
        nameLabel.textColor = Theme.Colors.HighlightLightColor.color
        usernameLabel.textColor = Theme.Colors.HighlightLightColor.color
        tweetContentLabel.textColor = regFontColor
        
        AvatarImageView.layer.cornerRadius = 4
        AvatarImageView.clipsToBounds = true
        
        tweetBackgroundView.layer.cornerRadius = 4
        tweetBackgroundView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
