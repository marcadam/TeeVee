//
//  ExploreViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import MBProgressHUD

class ExploreViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let channelPagingCellID = "com.smartchannel.ChannelCollectionPagingViewCell"
    let channelCellID = "com.smartchannel.ChannelCollectionViewCell"

    private var channels: [Channel] = []
    private var featuredChannels: [Channel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let channelPagingCellNIB = UINib(nibName: "ChannelCollectionPagingViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelPagingCellNIB, forCellWithReuseIdentifier: channelPagingCellID)

        let channelCellNIB = UINib(nibName: "ChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: channelCellID)

        // Theming
        collectionView.backgroundColor = Theme.Colors.DarkBackgroundColor.color

        getChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getChannels() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        ChannelClient.sharedInstance.getExploreChannels { (channels, error) -> () in
            if let channels = channels {
                self.channels = channels
                self.featuredChannels = self.getFeaturedChannels(channels)
                self.collectionView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print(error)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }

    func getFeaturedChannels(channels: [Channel]) -> [Channel] {
        var featuredChannels = [Channel]()

        for channel in channels {
            if channel.curated?.type == "featured" {
                featuredChannels.append(channel)
            }
        }

        return featuredChannels
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if channels.count > 0 {
                return channels.count
            } else {
                return 0
            }
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelPagingCellID, forIndexPath: indexPath) as! ChannelCollectionPagingViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
            cell.channel = channels[indexPath.row]
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    var cellInset: CGFloat { return 14.0 }
    var infoViewHeight: CGFloat { return 33.0 }
    var pagingViewHeight: CGFloat { return 200.00 }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: pagingViewHeight)
        } else {
            let cellWidth = (collectionView.bounds.width - (cellInset * 3.0)) / 2.0
            let cellHeight = cellWidth + infoViewHeight
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(0,0,0,0)
        } else {
            return UIEdgeInsetsMake(cellInset, cellInset, cellInset, cellInset)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return cellInset
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return cellInset
        }
    }
}
