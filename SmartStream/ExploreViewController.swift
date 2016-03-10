//
//  ExploreViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let channelPagingCellID = "com.smartchannel.ChannelCollectionPagingViewCell"
    let channelCellID = "com.smartchannel.ChannelCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let channelPagingCellNIB = UINib(nibName: "ChannelCollectionPagingViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelPagingCellNIB, forCellWithReuseIdentifier: channelPagingCellID)

        let channelCellNIB = UINib(nibName: "ChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: channelCellID)

        collectionView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return 8
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelPagingCellID, forIndexPath: indexPath) as! ChannelCollectionPagingViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
            return cell
        }
    }
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 200.0)
        } else {
            let cellWidth = (collectionView.bounds.width - 42.0) / 2.0
            return CGSize(width: cellWidth, height: 180.0)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(0,0,0,0)
        } else {
            return UIEdgeInsetsMake(14,14,14,14)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 14
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 14
        }
    }
}
