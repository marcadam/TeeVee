//
//  MyChannelTableViewCell.swift
//  SmartStream
//
//  Created by Jerry on 3/13/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol MyChannelTableViewCellDelegate: class {
    func myChannelCell(myChannelCell: MyChannelTableViewCell)
}

class MyChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    var indexPath: NSIndexPath!

    weak var delegate: MyChannelTableViewCellDelegate?

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
        deleteButton.tintColor = Theme.Colors.HighlightColor.color
        backgroundColor = UIColor.clearColor()
    }

    @IBAction func onDeleteTapped(sender: UIButton) {
        delegate?.myChannelCell(self)
    }
}
