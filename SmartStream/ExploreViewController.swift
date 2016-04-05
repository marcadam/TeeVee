//
//  ExploreViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import MBProgressHUD

let RotateFeaturedChannelNotificatonKey = "com.teevee.RotateFeaturedChannelNotificaton"

protocol ExploreViewControllerDelegate: class {
    func exploreVC(sender: ExploreViewController, didPlayChannel channel: Channel)
}

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let channelPagingCellID = "com.teevee.ChannelCollectionPagingViewCell"
    let channelCellID = "com.teevee.ChannelCollectionViewCell"
    let sectionTitleArray = ["blank_title", "Popular Channels"]
    
    var channels: [Channel]? {
        didSet {
            let featured = getFeaturedChannels(channels!)
            featuredChannels = featured
        }
    }
    private var featuredChannels: [Channel] = []
    private var featuredChannelTimer: NSTimer?
    weak var delegate: ExploreViewControllerDelegate?
    private var refreshControl: UIRefreshControl!
    private var isFirst: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        let channelPagingCellNIB = UINib(nibName: "ChannelCollectionPagingViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelPagingCellNIB, forCellWithReuseIdentifier: channelPagingCellID)
        
        let channelCellNIB = UINib(nibName: "ChannelCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(channelCellNIB, forCellWithReuseIdentifier: channelCellID)
        
        // Theming
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        collectionView.backgroundColor = UIColor.clearColor()
        
        if channels == nil {
            getChannels(withHUD: true) { () -> () in
            //
            }
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        featuredChannelTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(rotateFeaturedChannelView), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if isFirst && channels == nil {
            self.isFirst = !self.isFirst
            MBProgressHUD.showHUDAddedTo(view, animated: true)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if let featuredChannelTimer = featuredChannelTimer {
            featuredChannelTimer.invalidate()
        }
    }

    func rotateFeaturedChannelView() {
        NSNotificationCenter.defaultCenter().postNotificationName(RotateFeaturedChannelNotificatonKey, object: self, userInfo: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getChannels(withHUD showHUD: Bool, completion: ()->()) {
        ChannelClient.sharedInstance.getDiscoverChannels { (channels, error) -> () in
            if let channels = channels {
                self.channels = channels
                self.collectionView.reloadData()
                if showHUD {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                completion()
            } else {
                debugPrint(error)
                if showHUD {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                completion()
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

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
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
            if channels?.count > 0 {
                return channels!.count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelPagingCellID, forIndexPath: indexPath) as! ChannelCollectionPagingViewCell
            cell.delegate = self
            cell.featuredChannels = featuredChannels
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
            cell.channel = channels![indexPath.row]
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.exploreVC(self, didPlayChannel: channels![indexPath.row])
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        getChannels(withHUD: false) { () -> () in
            self.refreshControl.endRefreshing()
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
            return UIEdgeInsetsMake(0, cellInset, cellInset, cellInset)
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "ExploreSectionCollectionReusableView", forIndexPath: indexPath) as! ExploreSectionCollectionReusableView
        headerView.sectionHeaderLabel.text = sectionTitleArray[indexPath.section]
        
        //return headerView
        return headerView
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeZero
        } else {
            return CGSizeMake(view.frame.width, 50)
        }
    }
}

extension ExploreViewController: ChannelCollectionPagingViewCellDelegate {
    func channelCollectionPageView(sender: ChannelCollectionPagingViewCell, didPlayChannel channel: Channel) {
        delegate?.exploreVC(self, didPlayChannel: channel)
    }

    func shouldInvalidateFeaturedChannelTimer(sender: ChannelCollectionPagingViewCell) {
        featuredChannelTimer?.invalidate()
    }
}
