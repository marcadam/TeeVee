//
//  EmptyChannelTableViewCell.swift
//  TeeVee
//
//  Created by Jerry on 3/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class EmptyChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var collectionChannels = [Channel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        let channelCellNIB = UINib(nibName: "EmptyChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: "EmptyChannelCollectionCell")
        collectionView.backgroundColor = Theme.Colors.BackgroundColor.color
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension EmptyChannelTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmptyChannelCollectionCell", forIndexPath: indexPath) as! EmptyChannelCollectionViewCell
        return cell
    }
}
