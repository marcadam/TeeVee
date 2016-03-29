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
    var featuredChannels: [Channel]?
    private let bgColor = Theme.Colors.BackgroundColor.color
    private let imageMargin: CGFloat = 12
    private let imageColumns: CGFloat = 3
    private let imageInnerMargin: CGFloat = 5
    
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
        if let channels = featuredChannels {
            return channels.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmptyChannelCollectionCell", forIndexPath: indexPath) as! EmptyChannelCollectionViewCell
        if let channels = featuredChannels {
            cell.channel = channels[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (bounds.width - imageMargin*2 - ((imageColumns - 1)*imageInnerMargin)) / imageColumns
        return CGSizeMake(size, size)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return imageInnerMargin
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return imageInnerMargin
    }

}
