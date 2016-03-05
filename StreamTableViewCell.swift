//
//  StreamTableViewCell.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {

    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var streamName: UILabel!

    var stream: Stream!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        streamImageView.image = UIImage(named: "placeholder")
        streamName.text = "Nature Stream"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
