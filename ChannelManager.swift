//
//  ChannelManager.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftPriorityQueue
import youtube_ios_player_helper
import TwitterKit

class ChannelManager: NSObject, SmartuPlayerDelegate {

    
    let myContext = UnsafeMutablePointer<()>()
    let twitterClient = TWTRAPIClient()
    var spinner: SpinnerView?
    
    var nativePlayer: AVQueuePlayer?
    var nativePlayerLayer: AVPlayerLayer?
    var nativePlayerView: UIView?
    var nativePlayerOverlay: UIView?
    
    var youtubePlayerView: SmartuPlayer?
    
    var webView: UIView?
    
    var channelId: String!
    var priorityQueue: PriorityQueue<ChannelItem>?
    var currItem: ChannelItem?
    var timeObserver: AnyObject?
    
    func updateBounds(containerView: UIView!) {
        playerContainerView?.bounds = containerView.bounds
        nativePlayerLayer!.frame = containerView.bounds
    }
    
    func playbackStatus(playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        if playerType == .Youtube {
            if status == .WillEnd {
                notifyItemAboutToEnd()
            } else if status == .DidEnd {
                notifyItemDidEnd()
            }
        }
    }
    
    var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            playerContainerView!.backgroundColor = UIColor.blackColor()
            
            nativePlayerView = UIView(frame: playerContainerView!.bounds)
            nativePlayerView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            nativePlayerView!.backgroundColor = UIColor.blackColor()
            
            nativePlayerLayer = AVPlayerLayer(player: self.nativePlayer)
            nativePlayerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
            nativePlayerLayer!.frame = nativePlayerView!.bounds
            nativePlayerView!.layer.addSublayer(nativePlayerLayer!)
            nativePlayerLayer!.needsDisplayOnBoundsChange = true
            nativePlayerView!.layer.needsDisplayOnBoundsChange = true
            playerContainerView!.addSubview(nativePlayerView!)
            
            nativePlayerOverlay = UIView(frame: nativePlayerView!.bounds)
            nativePlayerOverlay!.backgroundColor = UIColor.blackColor()
            nativePlayerOverlay!.alpha = 0.0
            nativePlayerOverlay!.userInteractionEnabled = false
            nativePlayerView!.addSubview(nativePlayerOverlay!)
            
            youtubePlayerView = YoutubePlayerView(playerType: .Youtube, containerView: playerContainerView!, playerDelegate: self)
            
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
    
    func aboutToEndTweet() {
        print("[MANAGER] aboutToEndTweet()")
        notifyItemAboutToEnd()
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "endTweet", userInfo: nil, repeats: false)
    }
    
    func endTweet() {
        print("[MANAGER] endTweet()")
        tweetView?.removeFromSuperview()
        notifyItemDidEnd()
    }
    
    var tweetView: TWTRTweetView?
    func playNextTweet(item: ChannelItem!) {
        print("[MANAGER] play next TweetItem")

        dispatch_async(dispatch_get_main_queue(),{
            self.twitterClient.loadTweetWithID(item.native_id!) { tweet, error in
                if let t = tweet {
                    self.tweetView = TWTRTweetView(tweet: t)
                    self.tweetView!.center = CGPointMake(self.playerContainerView!.bounds.size.width  / 2,
                        self.playerContainerView!.bounds.size.height / 2)
                    self.tweetView!.theme = .Light
                    self.showTweetView()
                    
                    self.playerContainerView?.addSubview(self.tweetView!)
                    self.playerContainerView?.bringSubviewToFront(self.tweetView!)
                    NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: "aboutToEndTweet", userInfo: nil, repeats: false)
                    
                } else {
                    print("Failed to load Tweet: \(error!.localizedDescription) ; \(error!.debugDescription)")
                }
            }
            
            self.currItem = item
        })
    }
    
    func playNextYoutubeItem(item: ChannelItem!) {
        youtubePlayerView?.startItem(item)
    }
    
    func playNextNativeItem(item: ChannelItem!) {
        print("[MANAGER] play next nativeItem")
        if item == currItem {return}
        //        nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: currItem)
        //        nativePlayer?.advanceToNextItem()
        dispatch_async(dispatch_get_main_queue(),{
            self.currItem = item
            //nativePlayer?.removeAllItems()
            //print(item.url!)
            self.nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: nil)
            self.nativePlayer?.play()
        })
    }
    
    init(channelId: String!) {
        super.init()
        
        self.channelId = channelId
        self.nativePlayer = AVQueuePlayer()
        self.nativePlayer!.addObserver(self, forKeyPath: "status", options: [.New], context: self.myContext)
        self.nativePlayer!.addObserver(self, forKeyPath: "currentItem", options: [.New], context: self.myContext)
        self.nativePlayer!.addObserver(self, forKeyPath: "duration", options: [.New], context: self.myContext)
        self.nativePlayer!.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New], context: self.myContext)
        self.nativePlayer!.addObserver(self, forKeyPath: "presentationSize", options: [.New], context: self.myContext)
        self.nativePlayer!.addObserver(self, forKeyPath: "error", options: [.New], context: self.myContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nativePlayerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserverForName(ItemDidEndNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: processItemEndEvent)
        NSNotificationCenter.defaultCenter().addObserverForName(ItemAboutToEndNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: processItemAboutToEndEvent)
        
        // an observer for every second playback
        timeObserver = nativePlayer!.addPeriodicTimeObserverForInterval(CMTimeMake(1,1), queue: nil, usingBlock: { (time: CMTime) -> Void in
            if self.nativePlayer != nil && self.nativePlayer!.currentItem != nil {
                let currentSecond = self.nativePlayer!.currentItem!.currentTime().value / Int64(self.nativePlayer!.currentItem!.currentTime().timescale)
                let totalDuration = CMTimeGetSeconds(self.nativePlayer!.currentItem!.duration)
                let totalDurationStr = String(format: "%.2f", totalDuration)
                //print("[NATIVEPLAYER] progress: \(currentSecond) / \(totalDurationStr) secs")
                
                if totalDuration == totalDuration && Int64(totalDuration) - currentSecond == bufferTimeConstant {
                    self.notifyItemAboutToEnd()
                }
            }
        })
    }
    
    deinit {
        stop()
        if timeObserver != nil {
            nativePlayer?.removeTimeObserver(timeObserver!)
        }
        self.nativePlayer?.removeObserver(self, forKeyPath: "status")
        self.nativePlayer?.removeObserver(self, forKeyPath: "currentItem")
        self.nativePlayer?.removeObserver(self, forKeyPath: "duration")
        self.nativePlayer?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.nativePlayer?.removeObserver(self, forKeyPath: "presentationSize")
        self.nativePlayer?.removeObserver(self, forKeyPath: "error")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func prepareYoutubeVideo() {
        youtubePlayerView?.playItem()
    }
    
    func fadeOutVideo(timer: NSTimer) {
        print("[MANAGER] fadeOutVideo()")
        let userInfo: [String : AnyObject] = timer.userInfo! as! [String : AnyObject]
        let item: ChannelItem! = userInfo["nextItem"] as! ChannelItem
        
        if self.currItem != nil {
            if self.currItem!.extractor == "youtube" {
                hideYoutubeView()
            } else if self.currItem!.extractor == "twitter" {
                hideTweetView()
            } else {
                hideNativeView()
            }
        }
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
            playNextYoutubeItem(item)
        } else if extractor == "twitter" {
            playNextTweet(item)
        } else {
            showNativeView()
            playNextNativeItem(item)
        }
        
        if priorityQueue!.count <= numItemsBeforeFetch {
            fetchMoreItems(false)
        }
    }
    
    func hidePlayerViews() {
        print("[MANAGER] hides all players")
        self.youtubePlayerView?.hide()
        self.nativePlayerView?.hidden = true
    }
    
    func hideYoutubeView() {
        self.youtubePlayerView?.hide()
    }
    
    func hideNativeView() {
        print("[MANAGER] fades out native player")
        self.nativePlayerOverlay?.alpha = 0.0
        self.nativePlayerView?.bringSubviewToFront(self.nativePlayerOverlay!)
        UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
            self.nativePlayerOverlay?.alpha = 1.0
        }
    }
    
    func hideTweetView() {
        print("[MANAGER] fades out tweet player")
        self.tweetView?.alpha = 1.0
        UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
            self.tweetView?.alpha = 0.0
        }
    }
    
    func showYoutubeView() {
        self.youtubePlayerView?.show()
    }
    
    func showNativeView() {
        print("[MANAGER] fades in native player")
        self.nativePlayerOverlay?.alpha = 1.0
        self.nativePlayerView?.bringSubviewToFront(self.nativePlayerOverlay!)
        UIView.animateWithDuration(fadeInTimeConstant) { () -> Void in
            self.nativePlayerOverlay?.alpha = 0.0
            self.playerContainerView?.bringSubviewToFront(self.nativePlayerView!)
            self.nativePlayerView?.hidden = false
        }
    }
    
    func showTweetView() {
        print("[MANAGER] fades in tweet player")
        self.tweetView?.alpha = 0.0
        UIView.animateWithDuration(fadeInTimeConstant) { () -> Void in
            self.tweetView?.alpha = 1.0
        }
    }
    
    func play() {
        if currItem == nil {return}
        
        if currItem!.extractor == "youtube" {
            youtubePlayerView?.playItem()
        } else if currItem!.extractor == "twitter" {
            
        } else {
            nativePlayer?.play()
        }
    }
    
    func pause() {
        nativePlayer?.pause()
        youtubePlayerView?.pauseItem()
    }
    
    func stop() {
        nativePlayer?.pause()
        nativePlayer?.replaceCurrentItemWithPlayerItem(nil)
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


// ==========================================================
// Option 1: Use native iOS player
// ==========================================================
extension ChannelManager {
    
    func nativePlayerDidFinishPlaying(notification: NSNotification) {
        if nativePlayer?.rate != 0 && nativePlayer?.error == nil {
            notifyItemDidEnd()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != myContext {return}
        let nativePlayer = object as? AVPlayer
        if (nativePlayer == nil || nativePlayer != self.nativePlayer) {return}
        
        if keyPath == "status" {
            
            if nativePlayer!.status == AVPlayerStatus.ReadyToPlay {
                print("[NATIVEPLAYER] ready to play")
                
                if let currentPlayerAsset = nativePlayer!.currentItem?.asset as? AVURLAsset {
                    if currItem != nil && currItem!.url == currentPlayerAsset.URL.absoluteString {
                        dispatch_async(dispatch_get_main_queue(),{
                            if nativePlayer!.currentItem != nil {
                                if let videoTrack = nativePlayer!.currentItem!.asset.tracksWithMediaType(AVMediaTypeVideo).first {
                                    print("naturalSize = \(videoTrack.naturalSize)")
                                    //print("preferredTransform = \(videoTrack.preferredTransform)")
                                }
                            }
                            self.nativePlayer?.play()
                        })
                    }
                }
            } else if nativePlayer!.status == AVPlayerStatus.Failed {
                print("[NATIVEPLAYER] failed to play")
            } else {
                print("[NATIVEPLAYER] unhandled playerItem status \(nativePlayer!.status)")
            }
            
        } else if keyPath == "currentItem" {
            
        } else if keyPath == "duration" {
            
            if let timeInterval = nativePlayer!.currentItem?.duration {
                let totalDuration = CMTimeGetSeconds(timeInterval)
                print("totalDuration = \(totalDuration)")
            }
            
        } else if keyPath == "loadedTimeRanges" {
        } else if keyPath == "presentationSize" {
        } else if keyPath == "error" {
            
        }
    }
    
}


// ==========================================================
// Option 3: Use web view player
// ==========================================================
extension ChannelManager {
    
}