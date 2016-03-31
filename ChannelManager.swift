//
//  ChannelManager.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import SwiftPriorityQueue
import MBProgressHUD


let TwitterEnabledKey = "kTwitterEnabled"

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
    private var spinnerShowing = false
    
    private var players = [SmartuPlayer]()
    private var nativePlayerView: SmartuPlayer?
    private var youtubePlayerView: SmartuPlayer?
    private var tweetPlayerView: SmartuPlayer?
    private var currPlayer: SmartuPlayer?
    
    private var channelId: String!
    private var channel: Channel!
    private var priorityQueue: PriorityQueue<ChannelItem>?
    
    private var tweetsPriorityQueues: [String: QueueWrapper]?
    private var pendingRequests = Array<((error: NSError?) -> ())>()
    private var numTweetsRequests = 0
    private var isPortrait = true
    
    private var currItem: ChannelItem?
    private var prevItem: ChannelItem?
    private var currTweetItem: ChannelItem?
    private var prevTweetItem: ChannelItem?
    private var isPlaying = false
    private var isTweetPlaying = false
    
    private var currProgress: Double = Double.NaN
    private var currTotalDuration: Double = Double.NaN
    
    weak var delegate: ChannelManagerDelegate?
    
    var twitterOn = false {
        didSet {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(twitterOn, forKey: TwitterEnabledKey)
            userDefaults.synchronize()
            debugPrint("[ChannelManager] save twitterEnabled to = \(self.twitterOn)")
            
            if twitterOn {
                
                if tweetsPriorityQueues != nil && currItem != nil && currItem!.topic != nil {
                    if let queueWrapper = tweetsPriorityQueues![currItem!.topic!] {
                        // queue exists for topic
                        if queueWrapper.queue != nil && queueWrapper.queue!.count > numItemsBeforeFetch {
                            debugPrint("[ChannelManager] Twitter enabled")
                            playNextTweet(currItem)
                            return
                        }
                    }
                }
                
                fetchMoreTweetsItems({[weak self] (error) -> () in
                    if let strongSelf = self {
                        if error != nil {return}
                        
                        debugPrint("[ChannelManager] Twitter enabled")
                        strongSelf.playNextTweet(strongSelf.currItem)
                    }
                })
                
            } else {
                debugPrint("[ChannelManager] Twitter disabled")
                isTweetPlaying = false
                tweetPlayerView?.stopItem()
            }
            
        }
    }
    
    weak var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView!.backgroundColor = Theme.Colors.DarkBackgroundColor.color
            
            if nativePlayerView == nil {
                nativePlayerView = NativePlayerView(playerId: players.count, containerView: playerContainerView)
                let nativePlayer = nativePlayerView as! NativePlayerView
                nativePlayer.playerDelegate = self
                players.append(nativePlayerView!)
            }
            
            if youtubePlayerView == nil {
                youtubePlayerView = YoutubePlayerView(playerId: players.count, containerView: playerContainerView)
                let youtubePlayer = youtubePlayerView as! YoutubePlayerView
                youtubePlayer.playerDelegate = self
                players.append(youtubePlayerView!)
            }
        }
    }
    
    weak var tweetsContainerView: UIView? {
        didSet {
            if tweetsContainerView == nil {return}
            tweetsContainerView!.backgroundColor = UIColor.clearColor()
            
            if tweetPlayerView == nil {
                tweetPlayerView = TweetPlayerView(playerId: players.count, containerView: tweetsContainerView)
                let tweetPlayer = tweetPlayerView as! TweetPlayerView
                tweetPlayer.playerDelegate = self
                players.append(tweetPlayerView!)
            }
            
        }
    }
    
    weak var spinnerContainerView: UIView? {
        didSet {
            if spinnerContainerView == nil {return}
            showSpinner(0)
        }
    }
    
    init(channelId: String, autoplay: Bool) {
        debugPrint("[ChannelManager] init()")
        self.twitterOn = false

        super.init()
        self.channelId = channelId
        self.priorityQueue = PriorityQueue(ascending: true, startingValues: [])
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let keyExists = userDefaults.objectForKey(TwitterEnabledKey) {
            self.twitterOn = userDefaults.boolForKey(TwitterEnabledKey)
            debugPrint("[ChannelManager] restore twitterEnabled to = \(self.twitterOn)")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveItemInProgress), name: AppWillTerminateNotificationKey, object: nil)
        
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            self.fetchMoreTweetsItems({[weak self] (error) -> () in
                if let strongSelf = self {
                    if error != nil {return}
                    
                    if strongSelf.twitterOn {
                        debugPrint("[ChannelManager] init: Twitter enabled")
                        strongSelf.playNextTweet(strongSelf.currItem)
                    }
                }
            })
            
            ChannelClient.sharedInstance.getChannel(channelId) {[weak self] (channel, error) -> () in
                if let strongSelf = self {
                    if channel != nil && channel!.items!.count > 0 {
                        debugPrint("[ChannelManager] loading initial channel items...")
                        strongSelf.channel = channel!
                        
                        let itemInProgress = strongSelf.channel.getItemInProgress()
                        if itemInProgress.item != nil {
                            debugPrint("[ChannelManager] restore item-in-progress")
                            debugPrint("[ChannelManager] inserting \(itemInProgress.item!.extractor!) in-progress item: \(itemInProgress.item!.native_id!); progress = \(itemInProgress.seconds)")
                            itemInProgress.item!.priority = 99
                            itemInProgress.item!.seekToSeconds = itemInProgress.seconds
                            self!.priorityQueue!.push(itemInProgress.item!)
                            strongSelf.channel.setItemInProgress(ItemInProgress(item: nil, seconds: Float.NaN))
                        }
                        
                        for item in channel!.items! {
                            debugPrint("[ChannelManager] inserting \(item.extractor!) item: \(item.native_id!)")
                            self!.priorityQueue!.push(item)
                        }
                        
                        if autoplay {
                            strongSelf.playNextItem()
                        }
                    } else {
                        strongSelf.fetchMoreItems(autoplay)
                    }
                }
            }
            
        })
    }
    
    func saveItemInProgress() {
        if currItem != nil && currTotalDuration != Double.NaN && currProgress != Double.NaN && currProgress < currTotalDuration {
            debugPrint("[ChannelManager] save item-in-progress")
            debugPrint("[ChannelManager] saving \(currItem!.extractor!) in-progress item: \(currItem!.native_id!); progress = \(currProgress)")
            self.channel.setItemInProgress(ItemInProgress(item: currItem, seconds: Float(currProgress)))
        }
    }
    
    deinit {
        debugPrint("[ChannelManager] deinit()")
        
        saveItemInProgress()
        stop()
        
        youtubePlayerView = nil
        nativePlayerView = nil
        tweetPlayerView = nil
        
        priorityQueue = nil
        tweetsPriorityQueues = nil
        
        pendingRequests.removeAll()
        numTweetsRequests = 0
        
        spinnerShowing = false
        isPlaying = false
        isTweetPlaying = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func playbackStatus(playerId: Int, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if playerType == .Tweet {
            if status == .DidEnd {
                isTweetPlaying = false
                prevTweetItem = currTweetItem
                if twitterOn {
                    playNextTweet(currItem)
                    isTweetPlaying = true
                }
            } else if status == .Playing {
                // Tweet
            }
        } else {
            if status == .WillEnd {
                prepareNextItem()
            } else if status == .DidEnd {
                isPlaying = false
                prevItem = currItem
                showSpinner(Int64(1.0 * Double(NSEC_PER_SEC)))
                playNextItem()
                isPlaying = true
            } else if status == .Playing {
                currProgress = progress
                currTotalDuration = totalDuration
                
                let progressStr = String(format: "%.2f", progress)
                let totalDurationStr = String(format: "%.2f", totalDuration)
                debugPrint("[MANAGER] progress: \(progressStr) / \(totalDurationStr)")
                delegate?.channelManager(self, progress: progress, totalDuration: totalDuration)
                
                if spinnerShowing {
                    if totalDuration.isNaN {
                        debugPrint("[MANAGER] totalDuration isNaN")
                    }
                    removeSpinner()
                }
            }
        }
    }
    
    // Prepare for next item
    private var currCueId: String! = ""
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
        if isPlaying || priorityQueue == nil {return}
        
        var item: ChannelItem? = nil
        while true {
            if priorityQueue!.count == 0 {break}
            item = priorityQueue!.pop()
            if item != nil && item?.native_id != nil {
                if prevItem != nil && prevItem?.extractor == item!.extractor && prevItem!.native_id == item!.native_id {
                    // remove back-to-back duplicate items
                    continue
                }
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
    
    func playNextTweet(channelItem: ChannelItem?) {
        if isTweetPlaying || channelItem == nil || channelItem?.topic == nil {return}
        
        if let queueWrapper = tweetsPriorityQueues![channelItem!.topic!] {
            if queueWrapper.queue == nil {return}
            
            var tweetItem: ChannelItem? = nil
            while true {
                if queueWrapper.queue!.count == 0 {break}
                tweetItem = queueWrapper.queue!.pop()
                //debugPrint("[MANAGER] queue.count = \(queueWrapper.queue!.count)")
                if tweetItem != nil && tweetItem?.native_id != nil && tweetItem?.extractor == "twitter" {
                    if prevTweetItem != nil && prevTweetItem!.tweet != nil && tweetItem!.tweet != nil && prevTweetItem!.tweet!.text == tweetItem!.tweet!.text {
                        // remove back-to-back duplicate tweets
                        continue
                    }
                    break
                }
            }
            if tweetItem == nil {return}
            debugPrint("[MANAGER] extractor = \(tweetItem!.extractor); id = \(tweetItem!.native_id)")
            
            currTweetItem = tweetItem
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
        
        //currItem = nil
        //currTweetItem = nil
    }
    
    func next() {
        isPlaying = false
        currPlayer?.stopItem()
        tweetPlayerView?.nextItem()
        
        showSpinner(0)
        playNextItem()
    }
    
    private var twitterPausedDueToRotation = false
    func onRotation(isPortrait: Bool) {
        if self.isPortrait == isPortrait {return}
        self.isPortrait = isPortrait
        
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
        if spinnerShowing {return}
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(),{
            [weak self] in
            
            if let strongSelf = self {
                if strongSelf.isPlaying {return}
                
                debugPrint("[MANAGER] showSpinner()")
                MBProgressHUD.showHUDAddedTo(strongSelf.spinnerContainerView, animated: true)
                strongSelf.spinnerShowing = true
            }
        })
    }
    
    func removeSpinner() {
        dispatch_async(dispatch_get_main_queue(),{
            [weak self] in
            
            if let strongSelf = self {
                if !strongSelf.spinnerShowing  {return}
                debugPrint("[MANAGER] removeSpinner()")
                MBProgressHUD.hideHUDForView(strongSelf.spinnerContainerView, animated: true)
                strongSelf.spinnerShowing = false
            }
        })
    }
    
    func fetchMoreItems(autoplay: Bool) {
        debugPrint("[MANAGER] fetchMoreItems()")
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            [weak self] in
            if self == nil {return}
            
            ChannelClient.sharedInstance.streamChannel(self!.channelId) { (channel, error) -> () in
                if self == nil {return}
                
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        self!.priorityQueue!.push(item)
                    }
                    
                    if autoplay {
                        self!.playNextItem()
                    }
                }
            }
        })
    }
    
    func fetchMoreTweetsItems(completion: ((error: NSError?) -> ())?) {
        if completion != nil {
            pendingRequests.append(completion!)
        }
        numTweetsRequests += 1
        if numTweetsRequests > 1 {
            // guard against duplicate fetch
            debugPrint("[MANAGER] already fetching Tweets, numRequests = \(numTweetsRequests)")
            return
        }
        
        debugPrint("[MANAGER] fetchMoreTweetItems()")
        
        if tweetsPriorityQueues == nil {
            tweetsPriorityQueues = [String: QueueWrapper]()
        }
        
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            [weak self] in
            if self == nil {return}
            
            ChannelClient.sharedInstance.getTweetsForChannel(self!.channelId) { (channel, error) -> () in
                if self == nil {return}
                
                if channel != nil && channel!.items!.count > 0 {
                    for item in channel!.items! {
                        if item.topic == nil || item.topic == "" {continue}
                        
                        var queue: PriorityQueue<ChannelItem>? = nil
                        if let queueWrapper = self!.tweetsPriorityQueues![item.topic!] {
                            // queue exists for topic
                            queueWrapper.queue?.push(item)
                            debugPrint("[ChannelManager] TWEET inserting \(item.extractor!) item: \(item.native_id!)")
                        } else {
                            queue = PriorityQueue<ChannelItem>(ascending: true, startingValues: [])
                            queue!.push(item)
                            let newQueueWrapper = QueueWrapper(queue: queue)
                            self!.tweetsPriorityQueues![item.topic!] = newQueueWrapper
                        }
                    }
                    
                    for request in self!.pendingRequests {
                        request(error: error)
                    }
                    self!.pendingRequests.removeAll()
                    self!.numTweetsRequests = 0
                }
            }
        })
    }
}

