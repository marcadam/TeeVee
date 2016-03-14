//
//  ChannelManager.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import SwiftPriorityQueue
import TwitterKit

class ChannelManager: NSObject, SmartuPlayerDelegate {

    let twitterClient = TWTRAPIClient()
    var spinner: SpinnerView?
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    
    var players = [SmartuPlayer]()
    var nativePlayerView: SmartuPlayer?
    var youtubePlayerView: SmartuPlayer?
    var tweetPlayerView: SmartuPlayer?
    var currPlayer: SmartuPlayer?
    
    var channelId: String!
    var priorityQueue: PriorityQueue<ChannelItem>?
    var currItem: ChannelItem?
    var timeObserver: AnyObject?
    
    var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView!.backgroundColor = UIColor.blackColor()
            
            nativePlayerView = NativePlayerView(playerId: 0, containerView: playerContainerView!, playerDelegate: self)
            youtubePlayerView = YoutubePlayerView(playerId: 1, containerView: playerContainerView!, playerDelegate: self)
            tweetPlayerView = TweetPlayerView(playerId: 2, containerView: playerContainerView!, playerDelegate: self)
            players.append(nativePlayerView!)
            players.append(youtubePlayerView!)
            players.append(tweetPlayerView!)
            
            spinner = SpinnerView(frame: UIScreen.mainScreen().bounds)
            spinner!.hidden = false
            spinner!.startAnimating()
            playerContainerView!.addSubview(spinner!)
            playerContainerView!.bringSubviewToFront(spinner!)
        }
    }
    
    var channel: Channel? {
        didSet {
            
            if channel == nil || channel!.items!.count == 0 {
                priorityQueue = PriorityQueue()
                fetchMoreItems(true)
            } else {
                removeSpinner()
                priorityQueue = PriorityQueue(ascending: true, startingValues: channel!.items!)
                playNextItem()
            }
            
        }
    }
    
    init(channelId: String!) {
        super.init()
        
        self.channelId = channelId
        
        NSNotificationCenter.defaultCenter().addObserverForName(ItemDidEndNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: processItemEndEvent)
        NSNotificationCenter.defaultCenter().addObserverForName(ItemAboutToEndNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: processItemAboutToEndEvent)
    }
    
    deinit {
        stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Prepare for next item
    var currCueId: String! = ""
    func prepareNextItem() {
        let item = priorityQueue!.peek()
        if item == nil || item!.native_id == nil || currCueId == item!.native_id! {return}
        currCueId = item!.native_id!
        
        let extractor = item!.extractor
        if extractor == "youtube" {
            if currItem != nil && currItem!.extractor != "youtube" {
                // cue in youtube player if previous item was not Youtube
                youtubePlayerView?.prepareToStart(item!)
            }
        }
        
        let userInfo: [String : AnyObject] = ["nextItem" : item!]
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "fadeOutVideo:", userInfo: userInfo, repeats: false)
    }
    
    func fadeOutVideo(timer: NSTimer) {
        let userInfo: [String : AnyObject] = timer.userInfo! as! [String : AnyObject]
        let item: ChannelItem! = userInfo["nextItem"] as! ChannelItem
        
        if item != nil && item == currItem {
            print("[MANAGER] fadeOutVideo()")
            currPlayer?.hide(nil)
        }
    }
    
    func playNextItem() {
        
        var item: ChannelItem? = nil
        while priorityQueue!.count > 0 && (item == nil || item!.native_id == nil) {
            item = priorityQueue!.pop()
        }
        if item == nil {
            stop()
            return
        }
        
        let extractor = item!.extractor
        print("[MANAGER] extractor = \(item!.extractor); id = \(item!.native_id); url = \(item!.url)")
        
        currItem = item
        if extractor == "youtube" {
            currPlayer = youtubePlayerView
            youtubePlayerView?.startItem(item!)
        } else if extractor == "twitter" {
            currPlayer = tweetPlayerView
            tweetPlayerView?.startItem(item!)
        } else {
            currPlayer = nativePlayerView
            nativePlayerView?.startItem(item!)
        }
        
        if priorityQueue!.count <= numItemsBeforeFetch {
            fetchMoreItems(false)
        }
    }
    
    func updateBounds(containerView: UIView!) {
        playerContainerView?.bounds = containerView.bounds
        for player in players {
            player.resetBounds(containerView.bounds)
        }
    }
    
    func playbackStatus(playerId: Int, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if status == .WillEnd {
            notifyItemAboutToEnd()
        } else if status == .DidEnd {
            notifyItemDidEnd()
        }
    }
    
    func notifyItemAboutToEnd() {
        NSNotificationCenter.defaultCenter().postNotificationName(ItemAboutToEndNotification, object: self, userInfo: nil)
    }
    
    func notifyItemDidEnd() {
        NSNotificationCenter.defaultCenter().postNotificationName(ItemDidEndNotification, object: self, userInfo: nil)
    }
    
    func processItemAboutToEndEvent(notification: NSNotification) -> Void {
        print("[MANAGER] processItemAboutToEndEvent")
        prepareNextItem()
    }
    
    func processItemEndEvent(notification: NSNotification) -> Void {
        print("[MANAGER] processItemEndEvent")
        playNextItem()
    }
    
    func play() {
        if currItem == nil || currPlayer == nil {return}
        currPlayer?.playItem()
    }
    
    func pause() {
        if currItem == nil || currPlayer == nil {return}
        for player in players {
            player.pauseItem()
        }
    }
    
    func stop() {
        if currItem == nil || currPlayer == nil {return}
        for player in players {
            player.stopItem()
        }
    }
    
    func next() {
        stop()
        playNextItem()
    }
    
    
    func removeSpinner() {
        if self.spinner != nil && self.spinner!.isDescendantOfView(self.playerContainerView!) {
            dispatch_async(dispatch_get_main_queue(),{
                self.spinner?.stopAnimating()
                self.spinner?.removeFromSuperview()
            })
        }
    }
    
    func fetchMoreItems(autoplay: Bool) {
        print("[MANAGER] fetchMoreItems()")
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            ChannelClient.sharedInstance.streamChannel(self.channelId) { (channel, error) -> () in
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        self.priorityQueue!.push(item)
                    }
                    
                    // check if currently playing, if not, restart
                }
            }
        })
    }
}

