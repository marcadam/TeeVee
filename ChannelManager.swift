//
//  ChannelManager.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import SwiftPriorityQueue

protocol ChannelManagerDelegate: class {
    func channelManager(channelManager: ChannelManager, progress: Double, totalDuration: Double)
}

class QueueWrapper: NSObject {
    var queue: PriorityQueue<ChannelItem>?
    
    init(queue: PriorityQueue<ChannelItem>?) {
        self.queue = queue
        super.init()
    }
}

class ChannelManager: NSObject, SmartuPlayerDelegate {

    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    private var spinner: SpinnerView?
    private var spinnerShowing = false
    
    private var players = [SmartuPlayer]()
    private var nativePlayerView: SmartuPlayer?
    private var youtubePlayerView: SmartuPlayer?
    private var tweetPlayerView: SmartuPlayer?
    private var currPlayer: SmartuPlayer?
    
    private var channelId: String?
    private var priorityQueue: PriorityQueue<ChannelItem>?
    private var currItem: ChannelItem?
    
    private var tweetsPriorityQueues: [String: QueueWrapper]?
    private var pendingRequests = Array<((error: NSError?) -> ())>()
    private var numTweetsRequests = 0
    private var isPortrait = true
    
    weak var delegate: ChannelManagerDelegate?
    
    var twitterOn = false {
        didSet {
            
            if twitterOn {
                
                if tweetsPriorityQueues != nil && currItem != nil && currItem!.topic != nil {
                    if let queueWrapper = tweetsPriorityQueues![currItem!.topic!] {
                        // queue exists for topic
                        if queueWrapper.queue != nil && queueWrapper.queue!.count > numItemsBeforeFetch {
                            self.playNextTweet(self.currItem)
                            return
                        }
                    }
                }
                
                fetchMoreTweetsItems({ (error) -> () in
                    if error != nil {return}
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        self.playNextTweet(self.currItem)
                    })
                })
                
            } else {
                self.tweetPlayerView?.stopItem()
            }
        }
    }
    
    weak var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView?.backgroundColor = Theme.Colors.DarkBackgroundColor.color
            
            nativePlayerView = NativePlayerView(playerId: players.count, containerView: playerContainerView, playerDelegate: self)
            players.append(nativePlayerView!)
            youtubePlayerView = YoutubePlayerView(playerId: players.count, containerView: playerContainerView, playerDelegate: self)
            players.append(youtubePlayerView!)
            
            showSpinner(0)
        }
    }
    
    weak var tweetsContainerView: UIView? {
        didSet {
            if tweetsContainerView == nil {return}
            tweetsContainerView!.backgroundColor = UIColor.clearColor()
            
            tweetPlayerView = TweetPlayerView(playerId: players.count, containerView: tweetsContainerView, playerDelegate: self)
            players.append(tweetPlayerView!)
            
        }
    }
    
    init(channelId: String?, autoplay: Bool) {
        debugPrint("[ChannelManager] init()")
        super.init()
        self.channelId = channelId
        self.spinner = SpinnerView(frame: UIScreen.mainScreen().bounds)
        
        fetchMoreTweetsItems(nil)
        ChannelClient.sharedInstance.getChannel(channelId!) { (channel, error) -> () in
            if channel != nil && channel!.items!.count > 0 {
                
                self.priorityQueue = PriorityQueue(ascending: true, startingValues: channel!.items!)
                
                if autoplay {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.playNextItem()
                    })
                }
            }
        }
    }
    
    deinit {
        debugPrint("[ChannelManager] deinit()")
        stop()
        
        youtubePlayerView = nil
        nativePlayerView = nil
        tweetPlayerView = nil
        
        channelId = nil
        priorityQueue = nil
        tweetsPriorityQueues = nil
        spinner = nil
        
        pendingRequests.removeAll()
        numTweetsRequests = 0
        
        spinnerShowing = false
        twitterOn = false
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
    
    var prevItem: ChannelItem?
    func playNextItem() {
        if priorityQueue == nil {return}
        
        var item: ChannelItem? = nil
        while true {
            if priorityQueue!.count == 0 {break}
            item = priorityQueue!.pop()
            if item != nil && item?.native_id != nil {
                if prevItem != nil && prevItem?.extractor == item!.extractor && prevItem!.native_id == item!.native_id {
                    // remove back-to-back duplicate items
                    continue
                }
                prevItem = item
                break
            }
        }
        if item == nil {
            stop()
            return
        }
        
        let extractor = item?.extractor
        debugPrint("[MANAGER] extractor = \(item?.extractor); id = \(item?.native_id); url = \(item?.url)")
        
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
    
    var prevTweet: Tweet?
    func playNextTweet(channelItem: ChannelItem?) {
        if channelItem == nil || channelItem?.topic == nil {return}
        
        if let queueWrapper = self.tweetsPriorityQueues![channelItem!.topic!] {
            if queueWrapper.queue == nil {return}
            
            var tweetItem: ChannelItem? = nil
            while true {
                if queueWrapper.queue!.count == 0 {break}
                tweetItem = queueWrapper.queue!.pop()
                //debugPrint("[MANAGER] queue.count = \(queueWrapper.queue!.count)")
                if tweetItem != nil && tweetItem?.native_id != nil && tweetItem?.extractor == "twitter" {
                    if prevTweet != nil && tweetItem?.tweet != nil && prevTweet?.text == tweetItem?.tweet?.text {
                        // remove back-to-back duplicate tweets
                        continue
                    }
                    prevTweet = tweetItem?.tweet
                    break
                }
            }
            if tweetItem == nil {return}
            debugPrint("[MANAGER] extractor = \(tweetItem!.extractor); id = \(tweetItem!.native_id)")
            
            tweetPlayerView?.startItem(tweetItem!)
            
            if queueWrapper.queue!.count <= numItemsBeforeFetch {
                fetchMoreTweetsItems(nil)
            }
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
        spinner?.frame = playerContainerView!.bounds
    }
    
    var isPlaying = false
    func playbackStatus(playerId: Int, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if playerType == .Tweet {
            if status == .DidEnd && twitterOn {
                playNextTweet(currItem)
            }
        } else {
            if status == .WillEnd {
                prepareNextItem()
            } else if status == .DidEnd {
                isPlaying = false
                showSpinner(Int64(1.0 * Double(NSEC_PER_SEC)))
                playNextItem()
            } else if status == .Playing {
                isPlaying = true
                let progressStr = String(format: "%.2f", progress)
                let totalDurationStr = String(format: "%.2f", totalDuration)
                debugPrint("[MANAGER] progress: \(progressStr) / \(totalDurationStr)")
                delegate?.channelManager(self, progress: progress, totalDuration: totalDuration)
                
                if spinnerShowing {
                    removeSpinner()
                }
            }
        }
    }
    
    func play() {
        if currItem == nil {return}
        currPlayer?.playItem()
        tweetPlayerView?.playItem()
    }
    
    func pause() {
        if currItem == nil {return}
        currPlayer?.pauseItem()
        tweetPlayerView?.pauseItem()
    }
    
    func stop() {
        if currItem == nil {return}
        currPlayer?.stopItem()
        tweetPlayerView?.stopItem()
    }
    
    func next() {
        isPlaying = false
        currPlayer?.stopItem()
        tweetPlayerView?.nextItem()
        playNextItem()
        showSpinner(0)
    }
    
    var twitterPausedDueToRotation = false
    func onRotation(application: UIApplication, isPortrait: Bool) {
        let newOrientation = application.statusBarOrientation.isPortrait
        if self.isPortrait == newOrientation {return}
        self.isPortrait = newOrientation
        
        if twitterOn {
            if !isPortrait {
                debugPrint("[MANAGER] pause Tweet due to rotation")
                twitterPausedDueToRotation = true
                tweetPlayerView?.pauseItem()
            } else {
                if twitterPausedDueToRotation {
                    debugPrint("[MANAGER] resume Tweet due to rotation")
                    twitterPausedDueToRotation = false
                    tweetPlayerView?.playItem()
                }
            }
        }
    }
    
    func showSpinner(delay: Int64) {
        if self.spinnerShowing {return}
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(),{
            if self.isPlaying || self.spinner == nil {return}
            
            debugPrint("[MANAGER] showSpinner()")
            self.spinnerShowing = true
            self.spinner!.hidden = false
            self.spinner!.startAnimating()
            self.playerContainerView?.addSubview(self.spinner!)
            self.playerContainerView?.bringSubviewToFront(self.spinner!)
        })
    }
    
    func removeSpinner() {
        if self.spinner != nil && self.spinner!.isDescendantOfView(self.playerContainerView!) {
            dispatch_async(dispatch_get_main_queue(),{
                if !self.spinnerShowing || self.spinner == nil {return}
                debugPrint("[MANAGER] removeSpinner()")
                self.spinnerShowing = false
                self.spinner!.hidden = true
                self.spinner!.stopAnimating()
                self.spinner!.removeFromSuperview()
            })
        }
    }
    
    func fetchMoreItems(autoplay: Bool) {
        debugPrint("[MANAGER] fetchMoreItems()")
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            ChannelClient.sharedInstance.streamChannel(self.channelId!) { (channel, error) -> () in
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        self.priorityQueue!.push(item)
                    }
                    
                    // check if currently playing, if not, restart
                }
            }
        })
    }
    
    func fetchMoreTweetsItems(completion: ((error: NSError?) -> ())?) {
        if completion != nil {
            pendingRequests.append(completion!)
        }
        numTweetsRequests++
        if numTweetsRequests > 1 {
            // guard against duplicate fetch
            debugPrint("[MANAGER] already fetching Tweets, numRequests = \(numTweetsRequests)")
            return
        }
        
        debugPrint("[MANAGER] fetchMoreTweetItems()")
        
        if self.tweetsPriorityQueues == nil {
            self.tweetsPriorityQueues = [String: QueueWrapper]()
        }
        
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            ChannelClient.sharedInstance.getTweetsForChannel(self.channelId!) { (channel, error) -> () in
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        if item.topic == nil || item.topic == "" {continue}
                        
                        var queue: PriorityQueue<ChannelItem>? = nil
                        if let queueWrapper = self.tweetsPriorityQueues![item.topic!] {
                            // queue exists for topic
                            queueWrapper.queue?.push(item)
                        } else {
                            queue = PriorityQueue<ChannelItem>(ascending: true, startingValues: [])
                            queue!.push(item)
                            let newQueueWrapper = QueueWrapper(queue: queue)
                            self.tweetsPriorityQueues![item.topic!] = newQueueWrapper
                        }
                    }
                    
                    for request in self.pendingRequests {
                        request(error: error)
                    }
                    self.pendingRequests.removeAll()
                    self.numTweetsRequests = 0
                }
            }
        })
    }
}

