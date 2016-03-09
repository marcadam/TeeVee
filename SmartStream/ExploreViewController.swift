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

    let channelCellID = "com.smartchannel.ChannelCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
        return cell
    }
}
