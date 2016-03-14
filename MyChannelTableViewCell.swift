//
//  MyChannelTableViewCell.swift
//  SmartStream
//
//  Created by Jerry on 3/13/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class MyChannelTableViewCell: UITableViewCell {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet var topicLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        wrapperView.backgroundColor = Theme.Colors.LightButtonColor.color
        wrapperView.layer.cornerRadius = 8
        
        topicLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        topicLabel.textColor = Theme.Colors.HighlightColor.color
        backgroundColor = UIColor.clearColor()
    }

    @IBAction func onDeleteTapped(sender: UIButton) {
        
    }
}
