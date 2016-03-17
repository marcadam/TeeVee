//
//  ProfileAvatarCell.swift
//  SmartStream
//
//  Created by Jerry on 3/17/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ProfileAvatarCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User! {
        didSet {
            if let userImage = user.imageUrl {
                setImageWithFade(userImage)
            } else {
                avatarImageView.image = UIImage(named: "user")
            }
            nameLabel.text = user.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clearColor()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        nameLabel.textColor = Theme.Colors.HighlightColor.color
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImageWithFade(url: String) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        avatarImageView.setImageWithURLRequest(request, placeholderImage: UIImage(named: "placeholder"), success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
            self.avatarImageView.image = image
            self.avatarImageView.layer.opacity = 0
            UIView.transitionWithView(self.avatarImageView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.avatarImageView.layer.opacity = 1
                }, completion: { (bool: Bool) -> Void in
                    //
            })
            }) { (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                //
        }
    }

}
