//
//  FilterSwitchCell.swift
//  SmartChannel
//
//  Created by Jerry on 3/6/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol FilterSwitchCellDelegate: class {
    func filterSwitchCell(filterSwitchCell: FilterSwitchCell, didSwitchOn: Bool)
}

class FilterSwitchCell: UITableViewCell {

    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var filterSwitch: UISwitch!
    weak var delegate: FilterSwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.clearColor()
        filterLabel.font = Theme.Fonts.LightNormalTypeFace.font
        filterLabel.textColor = Theme.Colors.HighlightColor.color
        filterSwitch.tintColor = Theme.Colors.HighlightLightColor.color
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onSwitchChange(sender: UISwitch) {
        self.delegate?.filterSwitchCell(self, didSwitchOn: sender.selected)
    }
    
}
