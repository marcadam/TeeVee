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
    
    var players = [SmartuPlayer]()
    var nativePlayerView: SmartuPlayer?
    var youtubePlayerView: SmartuPlayer?
    var tweetPlayerView: SmartuPlayer?
    
    var channelId: String!
    var priorityQueue: PriorityQueue<ChannelItem>?
    var currItem: ChannelItem?
    var timeObserver: AnyObject?
    
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
            
            hidePlayerViews()
            
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
    
    func removeSpinner() {
        if self.spinner != nil && self.spinner!.isDescendantOfView(self.playerContainerView!) {
            dispatch_async(dispatch_get_main_queue(),{
                self.spinner?.stopAnimating()
                self.spinner?.removeFromSuperview()
            })
        }
    }
    
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
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
    
    func prepareYoutubeVideo() {
        youtubePlayerView?.playItem()
    }
    
    // Pre-buffering to smoothen transition
    var currCueId: String! = ""
    func prepareNextItem() {
        let item = priorityQueue!.peek()
        if item == nil || item!.native_id == nil || currCueId == item!.native_id! {return}
        currCueId = item!.native_id!
        
        let extractor = item!.extractor
        if extractor == "youtube" {
            if currItem != nil && currItem!.extractor != "youtube" {
                print("[MANAGER] buffering: extractor = \(extractor!); id = \(item!.native_id!)")
                youtubePlayerView?.prepareToStart(item!)
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareYoutubeVideo", userInfo: nil, repeats: false)
            }
        } else {
            // native player buffering
        }
        
        let userInfo: [String : AnyObject] = ["nextItem" : item!]
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "fadeOutVideo:", userInfo: userInfo, repeats: false)
    }
    
    func fadeOutVideo(timer: NSTimer) {
        print("[MANAGER] fadeOutVideo()")
        let userInfo: [String : AnyObject] = timer.userInfo! as! [String : AnyObject]
        let item: ChannelItem! = userInfo["nextItem"] as! ChannelItem
        
        if self.currItem != nil {
            if self.currItem!.extractor == "youtube" {
                youtubePlayerView?.hide(nil)
            } else if self.currItem!.extractor == "twitter" {
                tweetPlayerView?.hide(nil)
            } else {
                nativePlayerView?.hide(nil)
            }
        }
    }
    
    func playNextItem() {
        var item: ChannelItem? = nil
        while (item == nil || item!.native_id == nil) && priorityQueue!.count > 0 {
            item = priorityQueue!.pop()
        }
        if item == nil {
            stop()
            return
        }
        
        let extractor = item!.extractor
        print("[MANAGER] extractor = \(item!.extractor); id = \(item!.native_id); url = \(item!.url)")
        
        if extractor == "youtube" {
            youtubePlayerView?.show(nil)
            youtubePlayerView?.startItem(item)
        } else if extractor == "twitter" {
            tweetPlayerView?.show(nil)
            tweetPlayerView?.startItem(item)
        } else {
            nativePlayerView?.show(nil)
            nativePlayerView?.startItem(item)
        }
        
        if priorityQueue!.count <= numItemsBeforeFetch {
            fetchMoreItems(false)
        }
    }
    
    func hidePlayerViews() {
        print("[MANAGER] hides all players")
        youtubePlayerView?.hide(0.0)
        nativePlayerView?.hide(0.0)
    }
    
    func play() {
        if currItem == nil {return}
        
        if currItem!.extractor == "youtube" {
            youtubePlayerView?.playItem()
        } else if currItem!.extractor == "twitter" {
            tweetPlayerView?.playItem()
        } else {
            nativePlayerView?.playItem()
        }
    }
    
    func pause() {
        nativePlayerView?.pauseItem()
        youtubePlayerView?.pauseItem()
        tweetPlayerView?.pauseItem()
//        for player in players {
//            player.pauseItem()
//        }
    }
    
    func stop() {
        nativePlayerView?.stopItem()
        youtubePlayerView?.stopItem()
    }
    
    func next() {
        stop()
        playNextItem()
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
}

