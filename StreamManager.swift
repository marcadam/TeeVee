//
//  StreamManager.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftPriorityQueue
import youtube_ios_player_helper

class StreamManager: NSObject {
    let ItemDidEndNotification = "com.smartu.streammanager.itemDidEnd"
    let ItemAboutToEndNotification = "com.smartu.streammanager.itemAboutToEnd"
    let bufferTimeConstant = 5
    let fadeInTimeConstant = 2.0
    let fadeOutItmeConstant = 3.0
    
    let youtubePlayerVars : [NSObject : AnyObject] = [
        "playsinline": 1 ,
        "controls": 0,
        "enablejsapi": 1,
        "autohide": 1,
        "autoplay" : 0,
        "modestbranding" : 1
    ]
    let myContext = UnsafeMutablePointer<()>()
    var spinner: SpinnerView?
    
    var nativePlayer: AVQueuePlayer?
    var nativePlayerLayer: AVPlayerLayer?
    var nativePlayerView: UIView?
    var nativePlayerOverlay: UIView?
    var youtubePlayerView: YTPlayerView?
    var youtubePlayerOverlay: UIView?
    var youtubeWebviewLoaded = false
    var webView: UIView?
    
    var priorityQueue: PriorityQueue<StreamItem>?
    var currItem: StreamItem?
    var timeObserver: AnyObject?
    
    func updateBounds(containerView: UIView!) {
        playerContainerView?.bounds = containerView.bounds
        nativePlayerLayer!.frame = containerView.bounds
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
            
            nativePlayerOverlay = UIView(frame: nativePlayerView!.frame)
            nativePlayerOverlay!.backgroundColor = UIColor.blackColor()
            nativePlayerOverlay!.alpha = 0.0
            nativePlayerOverlay!.userInteractionEnabled = false
            nativePlayerView!.addSubview(nativePlayerOverlay!)
            
            youtubePlayerView = YTPlayerView(frame: playerContainerView!.bounds)
            youtubePlayerView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            youtubePlayerView!.backgroundColor = UIColor.blackColor()
            youtubePlayerView!.delegate = self
            playerContainerView!.addSubview(youtubePlayerView!)
            
            youtubePlayerOverlay = UIView(frame: youtubePlayerView!.frame)
            youtubePlayerOverlay!.backgroundColor = UIColor.blackColor()
            youtubePlayerOverlay!.alpha = 0.0
            youtubePlayerOverlay!.userInteractionEnabled = false
            youtubePlayerView!.addSubview(youtubePlayerOverlay!)
            
            hidePlayerViews()
            
            spinner = SpinnerView(frame: UIScreen.mainScreen().bounds)
            spinner!.hidden = false
            spinner!.startAnimating()
            playerContainerView!.addSubview(spinner!)
            playerContainerView!.bringSubviewToFront(spinner!)
        }
    }
    
    var stream: Stream? {
        didSet {
            dispatch_async(dispatch_get_main_queue(),{
                self.spinner?.stopAnimating()
                self.spinner?.removeFromSuperview()
            })
            
            if stream == nil || stream!.items.count == 0 {return}
            priorityQueue = PriorityQueue(ascending: true, startingValues: stream!.items)
            
            // Autoplay
            playNextItem()
        }
    }
    
    func playNextYoutubeItem(item: StreamItem!) {
        print("[MANAGER] play next YoutubeItem")
        if item == currItem {return}
        dispatch_async(dispatch_get_main_queue(),{
            
            if !self.youtubeWebviewLoaded {
                self.youtubeWebviewLoaded = true
                self.youtubePlayerView?.loadWithVideoId(item.id!, playerVars: self.youtubePlayerVars)
            } else {
                if self.currItem != nil && self.currItem!.extractor != "youtube" {
                    // previous video is not youtube, so the video is already cued in
                    self.youtubePlayerView?.playVideo()
                } else {
                    self.youtubePlayerView?.loadVideoById(item.id!, startSeconds: 0.0, suggestedQuality: .Default)
                }
            }
            self.currItem = item
            
        })
    }
    
    func playNextNativeItem(item: StreamItem!) {
        print("[MANAGER] play next nativeItem")
        if item == currItem {return}
        //        nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: currItem)
        //        nativePlayer?.advanceToNextItem()
        dispatch_async(dispatch_get_main_queue(),{
            self.currItem = item
            //nativePlayer?.removeAllItems()
            self.nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: nil)
            self.nativePlayer?.play()
        })
    }
    
    override init() {
        super.init()
        
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
                
                if totalDuration == totalDuration && Int64(totalDuration) - currentSecond == self.bufferTimeConstant {
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
        self.youtubePlayerView?.playVideo()
    }
    
    func fadeOutVideo(timer: NSTimer) {
        print("[MANAGER] fadeOutVideo()")
        let userInfo: [String : AnyObject] = timer.userInfo! as! [String : AnyObject]
        let item: StreamItem! = userInfo["nextItem"] as! StreamItem
        
        if self.currItem != nil {
            if self.currItem!.extractor == "youtube" {
                hideYoutubeView()
            } else {
                hideNativeView()
            }
        }
    }
    
    // Pre-buffering to smoothen transition
    var currCueId: String! = ""
    func prepareNextItem() {
        let item = priorityQueue!.peek()
        if item == nil || currCueId == item!.id! {return}
        currCueId = item!.id!
        
        let extractor = item!.extractor
        if extractor == "youtube" {
            if currItem != nil && currItem!.extractor != "youtube" {
                print("[MANAGER] buffering: extractor = \(extractor!); id = \(item!.id!)")
                youtubePlayerView?.cueVideoById(item!.id!, startSeconds: 0.0, suggestedQuality: .Default)
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareYoutubeVideo", userInfo: nil, repeats: false)
            }
        } else {
            // native player buffering
        }
        
        let userInfo: [String : AnyObject] = ["nextItem" : item!]
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "fadeOutVideo:", userInfo: userInfo, repeats: false)
    }
    
    func playNextItem() {
        let item = priorityQueue!.pop()
        if item == nil {return}
        
        let extractor = item!.extractor
        print("[MANAGER] extractor = \(extractor!); id = \(item!.id!)")
        
        if extractor == "youtube" {
            playNextYoutubeItem(item)
        } else {
            showNativeView()
            playNextNativeItem(item)
        }
    }
    
    func hidePlayerViews() {
        print("[MANAGER] hides all players")
        self.youtubePlayerView?.hidden = true
        self.nativePlayerView?.hidden = true
    }
    
    func hideYoutubeView() {
        print("[MANAGER] fades out youtube player")
        self.youtubePlayerOverlay?.alpha = 0.0
        self.youtubePlayerView?.bringSubviewToFront(self.youtubePlayerOverlay!)
        UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
            self.youtubePlayerOverlay?.alpha = 1.0
        }
    }
    
    func hideNativeView() {
        print("[MANAGER] fades out native player")
        self.nativePlayerOverlay?.alpha = 0.0
        self.nativePlayerView?.bringSubviewToFront(self.nativePlayerOverlay!)
        UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
            self.nativePlayerOverlay?.alpha = 1.0
        }
    }
    
    func showYoutubeView() {
        print("[MANAGER] fades in youtube player")
        self.youtubePlayerOverlay?.alpha = 1.0
        self.youtubePlayerView?.bringSubviewToFront(self.youtubePlayerOverlay!)
        UIView.animateWithDuration(fadeInTimeConstant) { () -> Void in
            self.youtubePlayerOverlay?.alpha = 0.0
            self.playerContainerView?.bringSubviewToFront(self.youtubePlayerView!)
            self.youtubePlayerView?.hidden = false
        }
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
    
    func play() {
        if currItem == nil {return}
        
        if currItem!.extractor == "youtube" {
            youtubePlayerView?.playVideo()
        } else {
            nativePlayer?.play()
        }
    }
    
    func pause() {
        nativePlayer?.pause()
        youtubePlayerView?.pauseVideo()
    }
    
    func stop() {
        nativePlayer?.pause()
        nativePlayer?.replaceCurrentItemWithPlayerItem(nil)
        youtubePlayerView?.stopVideo()
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
extension StreamManager {
    
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
                            if let videoTrack = nativePlayer!.currentItem!.asset.tracksWithMediaType(AVMediaTypeVideo).first {
                                print("naturalSize = \(videoTrack.naturalSize)")
                                //print("preferredTransform = \(videoTrack.preferredTransform)")
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
// Option 2: Use youtube player
// ==========================================================
extension StreamManager: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("[YOUTUBEPLAYER] playerViewDidBecomeReady")
        self.youtubePlayerView?.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("[YOUTUBEPLAYER] didChangeToState \(state.rawValue)")
        if state == .Ended {
            print("[YOUTUBEPLAYER] video ended")
            notifyItemDidEnd()
        } else if state == .Playing {
            print("[YOUTUBEPLAYER] video playing")
            showYoutubeView()
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {
        print("[YOUTUBEPLAYER] didChangeToQuality \(quality.rawValue)")
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        let currentSecond = String(format: "%.2f", playTime)
        let totalDuration = playerView.duration()
        let totalDurationStr = String(format: "%.2f", playerView.duration())
//        print("[YOUTUBEPLAYER] progress: \(currentSecond) / \(totalDurationStr) secs")
        if Int(totalDuration) - Int(playTime) == bufferTimeConstant {
            notifyItemAboutToEnd()
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print("[YOUTUBEPLAYER] didPlayTime \(error.rawValue)")
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        return UIColor.whiteColor()
    }
}


// ==========================================================
// Option 3: Use web view player
// ==========================================================
extension StreamManager {
    
}