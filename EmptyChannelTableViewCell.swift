//
//  EmptyChannelTableViewCell.swift
//  TeeVee
//
//  Created by Jerry on 3/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol EmptyChannelDelegate: class {
    func emptyChannel(emptyChannel: EmptyChannelTableViewCell, didUpdateSelectedChannels channel: [Channel])
}

class EmptyChannelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var featuredChannels: [Channel]? {
        didSet {
            collectionView.reloadData()
        }
    }
    private let bgColor = Theme.Colors.BackgroundColor.color
    private let cellID = "com.teevee.ChannelCollectionViewCell"
    private var selectedChannels = [Channel]()
    
    weak var delegate: EmptyChannelDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = bgColor
        
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        let channelCellNIB = UINib(nibName: "ChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = bgColor
        collectionView.allowsMultipleSelection = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension EmptyChannelTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var infoViewHeight: CGFloat { return 33.0 }
    private var imageMargin: CGFloat { return 14.0 }
    private var imageColumns: CGFloat { return 2.0 }
    private var imageInnerMargin: CGFloat { return 14.0 }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let channels = featuredChannels {
            return channels.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
        if let channels = featuredChannels {
            cell.channel = channels[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let channels = featuredChannels {
            let channel = channels[indexPath.item]
            selectedChannels.append(channel)
            delegate?.emptyChannel(self, didUpdateSelectedChannels: selectedChannels)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if selectedChannels.count > 0 {
            if let channels = featuredChannels {
                let selected = channels[indexPath.item]
                for (index, channel) in selectedChannels.enumerate() {
                    if selected.channel_id == channel.channel_id {
                        selectedChannels.removeAtIndex(index)
                        delegate?.emptyChannel(self, didUpdateSelectedChannels: selectedChannels)
                        return
                    }
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (bounds.width - imageMargin*2 - ((imageColumns - 1)*imageInnerMargin)) / imageColumns
        return CGSizeMake(size, size+infoViewHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return imageInnerMargin
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return imageInnerMargin
    }
    
}
