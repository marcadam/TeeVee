//
//  ExploreSectionCollectionReusableView.swift
//  SmartStream
//
//  Created by Jerry on 3/16/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ExploreSectionCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        sectionHeaderLabel.textColor = Theme.Colors.HighlightColor.color
    }
}
