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
    var featuredChannels: [Channel]!
    let bgColor = Theme.Colors.BackgroundColor.color
    let imageMargin: CGFloat = 12
    let imageRows: CGFloat = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = bgColor
        
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        let channelCellNIB = UINib(nibName: "EmptyChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: "EmptyChannelCollectionCell")
        collectionView.backgroundColor = bgColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension EmptyChannelTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredChannels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmptyChannelCollectionCell", forIndexPath: indexPath) as! EmptyChannelCollectionViewCell
        cell.channel = featuredChannels[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (bounds.width - imageMargin*(imageRows+1)) / imageRows
        return CGSizeMake(size, size)
    }

}
