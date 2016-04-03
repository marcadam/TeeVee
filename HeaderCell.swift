//
//  HeaderCell.swift
//  TeeVee
//
//  Created by Jerry on 4/2/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol HeaderCellDelegate: class {
    func headerCell(sender: HeaderCell, didTapAddChannel tapped: Bool)
    func headerCell(sender: HeaderCell, didTapCheckChannel tapped: Bool, withButtonTitle title: String)
}

class HeaderCell: UITableViewCell {

    @IBOutlet weak var checkChannelButton: UIButton!
    @IBOutlet weak var addChannelImageView: UIImageView!
    
    weak var delegate: HeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Theme.Colors.DarkBackgroundColor.color
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        addChannelImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imageTapped() {
        delegate?.headerCell(self, didTapAddChannel: true)
    }
    
    @IBAction func onCheckChannelTapped(sender: UIButton) {
        delegate?.headerCell(self, didTapCheckChannel: true, withButtonTitle: sender.currentTitle!)
    }
}
