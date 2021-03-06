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
import Mixpanel

let TwitterEnabledKey = "kTwitterEnabled"

protocol ChannelManagerDelegate: class {
    func channelManager(channelManager: ChannelManager, progress: Double, totalDuration: Double)
    func channelManager(channelManager: ChannelManager, didStartChannelItem item: ChannelItem, withViews views: [UIView])
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
    
    private var readyPlayers = [SmartuPlayer]()
    
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
    private var playbackPaused = false
    
    private var currProgress: Double = Double.NaN
    private var currTotalDuration: Double = Double.NaN
    
    weak var delegate: ChannelManagerDelegate?
    
    weak var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView!.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        }
    }
    
    weak var tweetsContainerView: UIView? {
        didSet {
            if tweetsContainerView == nil {return}
            tweetsContainerView!.backgroundColor = UIColor.clearColor()
            
            if tweetPlayerView == nil {
                tweetPlayerView = TweetPlayerView(playerId: "tweets", containerView: tweetsContainerView)
                let tweetPlayer = tweetPlayerView as! TweetPlayerView
                tweetPlayer.playerDelegate = self
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
        debugPrint("[MANAGER] init()")

        super.init()
        self.channelId = channelId
        self.priorityQueue = PriorityQueue(ascending: true, startingValues: [])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(saveItemInProgress), name: AppWillTerminateNotificationKey, object: nil)
        
        let stopWatch = StopWatch()
        let tweetsStopWatch = StopWatch()
        
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            ChannelClient.sharedInstance.getChannel(channelId) {[weak self] (channel, error) -> () in
                if let strongSelf = self {
                    if channel != nil && channel!.items!.count > 0 {
                        debugPrint("[MANAGER] loading initial channel items...")
                        strongSelf.channel = channel!
                        
                        let itemInProgress = strongSelf.channel.getItemInProgress()
                        if itemInProgress.item != nil {
                            debugPrint("[MANAGER] restore item-in-progress")
                            //debugPrint("[MANAGER] inserting \(itemInProgress.item!.extractor!) in-progress item: \(itemInProgress.item!.native_id!); progress = \(itemInProgress.seconds)")
                            itemInProgress.item!.priority = 99
                            itemInProgress.item!.seekToSeconds = itemInProgress.seconds
                            self!.priorityQueue!.push(itemInProgress.item!)
                            strongSelf.channel.setItemInProgress(ItemInProgress(item: nil, seconds: Float.NaN))
                        }
                        
                        for item in channel!.items! {
                            //debugPrint("[MANAGER] inserting \(item.extractor!) item: \(item.native_id!)")
                            self!.priorityQueue!.push(item)
                        }
                        
                        debugPrint("[MANAGER] channel INITIALIZED in \(stopWatch.stop()) seconds")
            
                        if autoplay {
                            strongSelf.next()
                        }
                    } else {
                        strongSelf.fetchMoreItems(autoplay)
                    }
                }
            }
            
        })
        
        self.fetchMoreTweetsItems({ (error) in
            debugPrint("[MANAGER] tweets stream INITIALIZED in \(tweetsStopWatch.stop()) seconds")
            self.playNextTweet(self.currItem)
        })
    }
    
    func saveItemInProgress() {
        if channel != nil && currItem != nil && currTotalDuration != Double.NaN && currProgress != Double.NaN && currProgress < currTotalDuration {
            debugPrint("[MANAGER] save item-in-progress")
            debugPrint("[MANAGER] saving \(currItem!.extractor!) in-progress item: \(currItem!.native_id!); progress = \(currProgress)")
            self.channel.setItemInProgress(ItemInProgress(item: currItem, seconds: Float(currProgress)))
        }
    }
    
    deinit {
        debugPrint("[MANAGER] deinit()")
        
        saveItemInProgress()
        stop()
        
        tweetPlayerView = nil
        
        priorityQueue = nil
        tweetsPriorityQueues = nil
        
        pendingRequests.removeAll()
        numTweetsRequests = 0
        
        spinnerShowing = false
        isPlaying = false
        currPlayer = nil
        readyPlayers.removeAll()
        
        isTweetPlaying = false
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func isPlaying(item: ChannelItem!) -> Bool {
        if !playbackPaused && currItem != nil && item != nil && currItem!.extractor == item!.extractor && currItem!.native_id == item!.native_id {
            return true
        }
        
        return false
    }
    
    func playbackStatus(playerId: String, playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if playerType == .Tweet {
            if status == .DidEnd {
                isTweetPlaying = false
                prevTweetItem = currTweetItem
                playNextTweet(currItem)
            } else if status == .Playing {
                // Tweet
            }
        } else {
            if status == .WillEnd {
                
            } else if status == .DidEnd {
                next()
            } else if status == .DidStart {
                
                delegate?.channelManager(self, didStartChannelItem: currItem!, withViews: currPlayer!.getPlayerViews())
                debugPrint("[MANAGER] CURRENT VIEWS::::::::: \(currPlayer?.getPlayerViews())")
                
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
                    playNextTweet(currItem)
                    
                    if currItem != nil {
                        Mixpanel.sharedInstance().timeEvent("ChannelManager.percentageWatched")
                    }
                }
            } else if status == .Error {
                let currPlayerId = (currPlayer == nil) ? "nil": currPlayer!.getPlayerId()
                debugPrint("[MANAGER] Received ERROR from \(playerId); currPlayer = \(currPlayerId)")
                if currPlayer != nil && currPlayer!.getPlayerId() == playerId {
                    debugPrint("[MANAGER] Current player \(playerId) error, next()")
                    next()
                } else {
                    
                    // remove the erroneous player from the Ready queue
                    for i in 0 ..< readyPlayers.count {
                        if playerId == readyPlayers[i].getPlayerId() {
                            debugPrint("[MANAGER] READY QUEUE: Remove player \(playerId)")
                            readyPlayers.removeAtIndex(i)
                            break
                        }
                    }
                    
                }
            }
        }
    }
    
    func getNextItem() -> ChannelItem? {
        var item: ChannelItem? = nil
        while true {
            if priorityQueue == nil || priorityQueue!.count == 0 {break}
            item = priorityQueue!.pop()
            if item != nil && item?.native_id != nil {
                if prevItem != nil && prevItem?.extractor == item!.extractor && prevItem!.native_id == item!.native_id {
                    // remove back-to-back duplicate items
                    continue
                }
                
                break
            }
        }
        
        prevItem = item
        return item
    }
    
    func playNextItem() {
        debugPrint("[MANAGER] playNextItem()")
        
        if isPlaying {return}
        isPlaying = true
        
        reloadQueues()
        if readyPlayers.isEmpty {return}
        
        if currItem != nil {
            var percentage: Double = Double.NaN
            if currProgress != Double.NaN && currTotalDuration != Double.NaN && currTotalDuration != 0.0 {
                percentage = currProgress / currTotalDuration
            }
            let percentageStr = (percentage == Double.NaN ? "NA" : String(format: "%.2f", percentage))
            let progressStr = (currProgress == Double.NaN ? "NA" : String(format: "%.2f", currProgress))
            let totalDurationStr = (currTotalDuration == Double.NaN ? "NA" : String(format: "%.2f", currTotalDuration))
            
            Mixpanel.sharedInstance().track("ChannelManager.percentageWatched", properties: ["item": currItem!.native_id!, "source": currItem!.extractor!, "percentageWatched": percentageStr, "watched": progressStr, "duration": totalDurationStr])
        }
        currPlayer?.pauseItem()
        currPlayer = readyPlayers.removeFirst()
        currItem = (currPlayer == nil) ? nil: currPlayer?.getItem()
        
        if playerContainerView != nil {
            currPlayer?.resetBounds(playerContainerView!.bounds)
        }
        
        // guard against concurrent playback
        for player in readyPlayers {
            player.pauseItem()
        }
        
        Mixpanel.sharedInstance().track("ChannelManager.playNextItem()", properties: ["item": (currItem == nil ? "nil": currItem!.native_id!), "source": (currItem == nil ? "NA": currItem!.extractor!)])
        currPlayer?.playItem()
    }
    
    func createPlayerForItem(item: ChannelItem!) -> SmartuPlayer? {
        if item == nil || item?.extractor == nil {return nil}
        
        var newPlayer: SmartuPlayer? = nil
        if item!.extractor == "youtube" {
            let youtubePlayer = YoutubePlayerView(playerId: item!.native_id!, containerView: playerContainerView)
            youtubePlayer.playerDelegate = self
            newPlayer = youtubePlayer
        } else {
            let nativePlayer = NativePlayerView(playerId: item!.native_id!, containerView: playerContainerView)
            nativePlayer.playerDelegate = self
            newPlayer = nativePlayer
        }
        
        return newPlayer
    }
    
    // Reload the Ready queue to make sure there're enough players
    func reloadBufferQueue() {
        Mixpanel.sharedInstance().track("ChannelManager.reloadBufferQueue()")
        
        var counter = 0
        while true {
            if readyPlayers.count >= maxNumBufferPlayers || counter >= maxNumBufferPlayers {break}
            let item = getNextItem()
            if item == nil {break}
            
            let newPlayer = createPlayerForItem(item!)
            if newPlayer != nil {
                readyPlayers.append(newPlayer!)
                newPlayer?.bufferItem(item!)
            }
            
            counter += 1
        }
    }
    
    func reloadQueues() {
        if readyPlayers.count < maxNumBufferPlayers {
            reloadBufferQueue()
        }
        if priorityQueue!.count < maxItemsBeforeFetch {
            fetchMoreItems(false)
        }
    }
    
    func playNextTweet(channelItem: ChannelItem?) {
        if isTweetPlaying || channelItem == nil || channelItem?.topic == nil {return}
        
        isTweetPlaying = true
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
            debugPrint("[MANAGER] extractor = \(tweetItem!.extractor!); id = \(tweetItem!.native_id!)")
            
            currTweetItem = tweetItem
            tweetPlayerView?.startItem(tweetItem!)
            
            Mixpanel.sharedInstance().track("ChannelManager.playNextTweet()", properties: ["item": (currTweetItem == nil ? "nil": currTweetItem!.native_id!)])
            
            if queueWrapper.queue!.count < maxItemsBeforeFetch {
                fetchMoreTweetsItems(nil)
            }
        }
    }
    
    func updateBounds(playerContainerView: UIView?, tweetsContainerView: UIView?) {
        debugPrint("[MANAGER] updateBounds()")
        if playerContainerView != nil {
            self.playerContainerView?.bounds = playerContainerView!.bounds
            self.currPlayer?.resetBounds(playerContainerView!.bounds)
        }
        
        if tweetsContainerView != nil {
            self.tweetsContainerView?.bounds = tweetsContainerView!.bounds
            tweetPlayerView?.resetBounds(tweetsContainerView!.bounds)
        }
    }
    
    
    func playTweet() {
        Mixpanel.sharedInstance().track("ChannelManager.playTweet()")
        
        tweetPlayerView?.playItem()
        
        if tweetsPriorityQueues != nil {
            if currItem != nil && currItem!.topic != nil {
                if let queueWrapper = tweetsPriorityQueues![currItem!.topic!] {
                    // queue exists for topic
                    if queueWrapper.queue != nil && queueWrapper.queue!.count >= maxItemsBeforeFetch {
                        debugPrint("[MANAGER] Twitter enabled")
                        playNextTweet(currItem)
                    }
                } else {
                    fetchMoreTweetsItems({[weak self] (error) -> () in
                        if let strongSelf = self {
                            debugPrint("[MANAGER] Twitter enabled")
                            strongSelf.playNextTweet(strongSelf.currItem)
                        }
                    })
                }
            }
        } else {
            
            fetchMoreTweetsItems({[weak self] (error) -> () in
                if let strongSelf = self {
                    debugPrint("[MANAGER] Twitter enabled")
                    strongSelf.playNextTweet(strongSelf.currItem)
                }
            })
        }
    }
    
    func pauseTweet() {
        Mixpanel.sharedInstance().track("ChannelManager.pauseTweet()")
        debugPrint("[MANAGER] Twitter disabled")
        tweetPlayerView?.pauseItem()
    }
    
    func play() {
        Mixpanel.sharedInstance().track("ChannelManager.play()", properties: ["currItem": (currItem == nil ? "nil": currItem!.native_id!), "source": (currItem == nil ? "NA": currItem!.extractor!)])
        currPlayer?.playItem()
        playbackPaused = false
    }
    
    func pause() {
        Mixpanel.sharedInstance().track("ChannelManager.pause()", properties: ["currItem": (currItem == nil ? "nil": currItem!.native_id!), "source": (currItem == nil ? "NA": currItem!.extractor!)])
        currPlayer?.pauseItem()
        playbackPaused = true
    }
    
    func stop() {
        Mixpanel.sharedInstance().track("ChannelManager.stop()", properties: ["currItem": (currItem == nil ? "nil": currItem!.native_id!), "source": (currItem == nil ? "NA": currItem!.extractor!)])
        
        currPlayer?.stopItem()
        tweetPlayerView?.stopItem()
        
        //currItem = nil
        //currTweetItem = nil
    }
    
    func next() {
        Mixpanel.sharedInstance().track("ChannelManager.next()", properties: ["currItem": (currItem == nil ? "nil": currItem!.native_id!), "source": (currItem == nil ? "NA": currItem!.extractor!)])
        
        showSpinner(0)
        
        isPlaying = false
        currPlayer?.stopItem()
        currPlayer = nil
        
        tweetPlayerView?.nextItem()
        playNextItem()
    }
    
    private var twitterPausedDueToRotation = false
    func onRotation(isPortrait: Bool) {
        if self.isPortrait == isPortrait {return}
        self.isPortrait = isPortrait
        
        debugPrint("[MANAGER] onRotation()")
        
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
    
    func showSpinner(delay: Int64) {
        if spinnerShowing {return}
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(),{
            [weak self] in
            
            if let strongSelf = self {
                //if strongSelf.isPlaying {return}
                
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
        Mixpanel.sharedInstance().track("ChannelManager.fetchMoreItems()")
        
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
                        self!.next()
                    }
                }
            }
        })
    }
    
    func fetchMoreTweetsItems(completion: ((error: NSError?) -> ())?) {
        Mixpanel.sharedInstance().track("ChannelManager.fetchMoreTweetsItems()")
        
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
                let channelStr = (channel == nil) ? "nil": "\(channel!.items!.count)"
                debugPrint("[MANAGER] fetchMoreTweetItems() received response \(channelStr)")
                if self == nil {return}
                
                if channel != nil && channel!.items!.count > 0 {
                    debugPrint("[MANAGER] fetchMoreTweetItems() process response")
                    
                    for item in channel!.items! {
                        if item.topic == nil || item.topic == "" {continue}
                        
                        var queue: PriorityQueue<ChannelItem>? = nil
                        if let queueWrapper = self!.tweetsPriorityQueues![item.topic!] {
                            // queue exists for topic
                            queueWrapper.queue?.push(item)
                            //debugPrint("[MANAGER] TWEET inserting \(item.extractor!) item: \(item.native_id!)")
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

