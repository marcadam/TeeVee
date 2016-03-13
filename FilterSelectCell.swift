//
//  FilterSelectCell.swift
//  SmartChannel
//
//  Created by Jerry on 3/7/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class FilterSelectCell: UITableViewCell {

    @IBOutlet weak var filterTextLabel: UILabel!
    @IBOutlet weak var filterSymbolLabel: UILabel!
    @IBOutlet weak var filterMinuteLabel: UILabel!
    @IBOutlet weak var filterCheckImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clearColor()

        filterTextLabel.font = Theme.Fonts.LightNormalTypeFace.font
        filterTextLabel.textColor = Theme.Colors.HighlightColor.color

        filterSymbolLabel.font = Theme.Fonts.LightNormalTypeFace.font
        filterSymbolLabel.textColor = Theme.Colors.HighlightColor.color

        filterMinuteLabel.font = Theme.Fonts.LightNormalTypeFace.font
        filterMinuteLabel.textColor = Theme.Colors.HighlightColor.color
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
