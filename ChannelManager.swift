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
    var channel: Channel?
    var priorityQueue: PriorityQueue<ChannelItem>?
    var currItem: ChannelItem?
    
    var tweetsChannel: Channel?
    var tweetsPriorityQueue: PriorityQueue<ChannelItem>?
    var twitterOn = false {
        didSet {
            if twitterOn {
                self.playNextTweet()
            } else {
                self.tweetPlayerView?.stopItem()
            }
        }
    }
    
    weak var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView!.backgroundColor = Theme.Colors.DarkBackgroundColor.color
            
            nativePlayerView = NativePlayerView(playerId: players.count, containerView: playerContainerView!, playerDelegate: self)
            players.append(nativePlayerView!)
            youtubePlayerView = YoutubePlayerView(playerId: players.count, containerView: playerContainerView!, playerDelegate: self)
            players.append(youtubePlayerView!)
            
            spinner = SpinnerView(frame: UIScreen.mainScreen().bounds)
            spinner!.hidden = false
            spinner!.startAnimating()
            playerContainerView!.addSubview(spinner!)
            playerContainerView!.bringSubviewToFront(spinner!)
        }
    }
    
    weak var tweetsContainerView: UIView? {
        didSet {
            if tweetsContainerView == nil {return}
            tweetsContainerView!.backgroundColor = UIColor.clearColor()
            
            tweetPlayerView = TweetPlayerView(playerId: players.count, containerView: tweetsContainerView!, playerDelegate: self)
            players.append(tweetPlayerView!)
            
        }
    }
    
    init(channelId: String!, autoplay: Bool) {
        super.init()
        self.channelId = channelId
        
        ChannelClient.sharedInstance.getChannel(channelId) { (channel, error) -> () in
            if channel != nil && channel!.items!.count > 0 {
                self.channel = channel
                
                self.removeSpinner()
                self.priorityQueue = PriorityQueue(ascending: true, startingValues: channel!.items!)
                
                if autoplay {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.playNextItem()
                    })
                }
            }
        }
        
        ChannelClient.sharedInstance.getTweetsForChannel(channelId) { (tweetsChannel, error) -> () in
            if tweetsChannel != nil && tweetsChannel!.items!.count > 0 {
                self.tweetsChannel = tweetsChannel
                
                self.tweetsPriorityQueue = PriorityQueue(ascending: true, startingValues: tweetsChannel!.items!)
            }
        }
    }
    
    deinit {
        stop()
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
    }
    
    func playNextItem() {
        
        var item: ChannelItem? = nil
        while true {
            if priorityQueue!.count == 0 {break}
            item = priorityQueue!.pop()
            if item != nil && item?.native_id != nil {break}
        }
        if item == nil {
            stop()
            return
        }
        
        let extractor = item?.extractor
        print("[MANAGER] extractor = \(item?.extractor); id = \(item?.native_id); url = \(item?.url)")
        
        currItem = item
        if extractor == "youtube" {
            currPlayer = youtubePlayerView
            youtubePlayerView?.startItem(item!)
        } else if extractor != nil {
            currPlayer = nativePlayerView
            nativePlayerView?.startItem(item!)
        }
        
        if priorityQueue!.count <= numItemsBeforeFetch {
            fetchMoreItems(false)
        }
    }
    
    func playNextTweet() {
        var item: ChannelItem? = nil
        while true {
            if tweetsPriorityQueue!.count == 0 {break}
            item = tweetsPriorityQueue!.pop()
            if item != nil && item?.native_id != nil {break}
        }
        if item == nil {
            stop()
            return
        }
        
        let extractor = item!.extractor
        print("[MANAGER] extractor = \(item!.extractor); id = \(item!.native_id); url = \(item!.url)")
        
        if extractor == "twitter" {
            tweetPlayerView?.startItem(item!)
        }
        
        if tweetsPriorityQueue!.count <= numItemsBeforeFetch {
            fetchMoreTweetsItems(false)
        }
    }
    
    func updateBounds(playerContainerView: UIView?, tweetsContainerView: UIView?) {
        if playerContainerView != nil {
            self.playerContainerView?.bounds = playerContainerView!.bounds
            youtubePlayerView?.resetBounds(playerContainerView!.bounds)
            nativePlayerView?.resetBounds(playerContainerView!.bounds)
        }
        
        if tweetsContainerView != nil {
            self.tweetsContainerView?.bounds = tweetsContainerView!.bounds
            tweetPlayerView?.resetBounds(tweetsContainerView!.bounds)
        }
    }
    
    func playbackStatus(playerId: Int, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if playerType == .Tweet {
            if status == .DidEnd {
                if twitterOn {
                    playNextTweet()
                }
            }
        } else {
            if status == .WillEnd {
                prepareNextItem()
            } else if status == .DidEnd {
                playNextItem()
            }
        }
    }
    
    func play() {
        if currItem == nil || currPlayer == nil {return}
        currPlayer?.playItem()
    }
    
    func pause() {
        if currItem == nil || currPlayer == nil {return}
        currPlayer!.pauseItem()
    }
    
    func stop() {
        if currItem == nil || currPlayer == nil {return}
        currPlayer!.stopItem()
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
    
    func fetchMoreTweetsItems(autoplay: Bool) {
        print("[MANAGER] fetchMoreTweetItems()")
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            ChannelClient.sharedInstance.getTweetsForChannel(self.channelId) { (channel, error) -> () in
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        self.tweetsPriorityQueue!.push(item)
                    }
                }
            }
        })
    }
}

