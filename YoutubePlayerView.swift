//
//  YoutubePlayerView.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubePlayerView: NSObject {
    let youtubePlayerVars : [NSObject : AnyObject] = [
        "playsinline": 1 ,
        "controls": 0,
        "enablejsapi": 1,
        "autohide": 1,
        "autoplay" : 0,
        "modestbranding" : 1,
        "showinfo": 0,
        "rel": 0,
        "fs": 0,
        "iv_load_policy": 3
    ]
    
    let playerId: String
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var playerContainerView: UIView?
    
    private var youtubePlayerView: YTPlayerView!
    private var youtubePlayerOverlay: UIView!
    
    private var currItem: ChannelItem?
    private var currBounds: CGRect
    private var isPlaying = false
    private var isBuffering = false
    private var bufferingTimer: NSTimer?
    private var playEnabled = false
    
    private var playerReady = false
    private var didStart = false
    
    init(playerId: String, containerView: UIView?) {
        debugPrint("[YOUTUBEPLAYER] init(); playerId = \(playerId)")
        
        self.playerId = playerId
        self.playerType = .Youtube
        self.playerContainerView = containerView
        
        youtubePlayerView = YTPlayerView(frame: containerView!.bounds)
        youtubePlayerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        youtubePlayerView.backgroundColor = UIColor.clearColor()
        containerView!.addSubview(youtubePlayerView)
        
        youtubePlayerOverlay = UIView(frame: containerView!.bounds)
        youtubePlayerOverlay.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        youtubePlayerOverlay.backgroundColor = UIColor.blackColor()
        youtubePlayerOverlay.alpha = 1.0
        youtubePlayerOverlay.userInteractionEnabled = false
        containerView!.addSubview(youtubePlayerOverlay)
        
        currBounds = containerView!.bounds
        
        super.init()
        youtubePlayerView.delegate = self
    }
    
    deinit {
        debugPrint("[YOUTUBEPLAYER] deinit(); playerId = \(playerId)")
        bufferingTimer?.invalidate()
        youtubePlayerView.removeFromSuperview()
        youtubePlayerOverlay.removeFromSuperview()
    }
}


extension YoutubePlayerView: SmartuPlayer {
    
    
    func bufferItem(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] bufferItem(): extractor = \(item.extractor!); id = \(item.native_id!)")
        //self.youtubePlayerView.cueVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
        
        self.currItem = (item.copy() as! ChannelItem)
        playEnabled = false
        dispatch_async(dispatch_get_main_queue(),{
            
            self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
        })
    }
    
    func startItem(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] startItem()")
        //if item == currItem {return}
        
        self.currItem = (item.copy() as! ChannelItem)
        dispatch_async(dispatch_get_main_queue(),{
//            if !self.youtubeWebviewLoaded {
//                self.youtubeWebviewLoaded = true
//                self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
//            } else {
////                if self.videoAlreadyCued {
////                    debugPrint("[YOUTUBEPLAYER] YoutubeItem already cued - play now")
////                    self.youtubePlayerView.playVideo()
////                    self.videoAlreadyCued = false
////                } else {
//                if item.seekToSeconds.isNaN {
//                    self.youtubePlayerView.loadVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
//                } else {
//                    self.youtubePlayerView.loadVideoById(item.native_id!, startSeconds: item.seekToSeconds, suggestedQuality: .Default)
//                    //self.youtubePlayerView.seekToSeconds(item.seekToSeconds, allowSeekAhead: true)
//                }
////                }
//            }
            
            self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
        })
    }
    
    func playItem() {
        if !playEnabled {
            playEnabled = true
            bufferingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(checkForAds), userInfo: nil, repeats: false)
        }
        
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] playItem(); vid = \(currItem!.native_id!)")
        debugPrint("[YOUTUBEPLAYER] player State = \(youtubePlayerView.playerState().rawValue); fraction = \(youtubePlayerView.videoLoadedFraction()); playback quality = \(youtubePlayerView.playbackQuality().rawValue); vid = \(currItem!.native_id!)")
   
//        if !healthCheck() {
//            onPlaybackError()
//            return
//        }
        
        self.youtubePlayerView.playVideo()
    }
    
    func healthCheck() -> Bool {
        if !playerReady || youtubePlayerView.playerState() == .Unstarted {
            return false
        }
        
        return true
    }
    
    func stopItem() {
        debugPrint("[YOUTUBEPLAYER] stopItem()")
        self.bufferingTimer?.invalidate()
        self.currItem = nil
        self.youtubePlayerView.stopVideo()
        self.isBuffering = false
        self.isPlaying = false
        self.hide(0.0)
    }
    
    func pauseItem() {
        debugPrint("[YOUTUBEPLAYER] pauseItem()")
        self.youtubePlayerView.pauseVideo()
    }
    
    func nextItem() {
        debugPrint("[YOUTUBEPLAYER] nextItem()")
        //stopItem()
    }
    
    func resetBounds(bounds: CGRect) {
        if currBounds == bounds {return}
        currBounds = bounds
        
        debugPrint("[YOUTUBEPLAYER] resetBounds()")
        if youtubePlayerView != nil && youtubePlayerView.webView != nil {
            self.youtubePlayerView.webView.frame = bounds
        }
    }
    
    func getItem() -> ChannelItem? {
        return currItem
    }
    
    func getPlayerId() -> String {
        return playerId
    }
    
    func getPlayerViews() -> [UIView] {
        return [youtubePlayerView, youtubePlayerOverlay]
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            debugPrint("[YOUTUBEPLAYER] fades in youtube player")
            var du = fadeInTimeConstant
            if duration != nil {
                du = duration!
            }
            
            self.youtubePlayerOverlay.alpha = 1.0
            self.playerContainerView?.bringSubviewToFront(self.youtubePlayerView)
            self.playerContainerView?.bringSubviewToFront(self.youtubePlayerOverlay)
            UIView.animateWithDuration(du) { () -> Void in
                self.youtubePlayerOverlay.alpha = 0.0
            }
        })
    }
    
    func hide(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            debugPrint("[YOUTUBEPLAYER] fades out youtube player")
            var du = fadeOutTimeConstant
            if duration != nil {
                du = duration!
            }
            
            self.youtubePlayerOverlay.alpha = 0.0
            UIView.animateWithDuration(du) { () -> Void in
                self.youtubePlayerOverlay.alpha = 1.0
            }
            
            NSTimer.scheduledTimerWithTimeInterval(du, target: self, selector: #selector(self.removeViews), userInfo: nil, repeats: false)
        })
    }
    
    func removeViews() {
        self.youtubePlayerView.removeFromSuperview()
        self.youtubePlayerOverlay.removeFromSuperview()
    }
    
    func endItem() {
        bufferingTimer?.invalidate()
        hide(nil)
    }
    
    func onPlaybackError() {
        debugPrint("[YOUTUBEPLAYER] onPlaybackError(); vid = \(currItem!.native_id!)")
        bufferingTimer?.invalidate()
        isBuffering = false
        isPlaying = false
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Error, progress: 0.0, totalDuration: 0.0)
    }

}

extension YoutubePlayerView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] playerViewDidBecomeReady; vid = \(currItem!.native_id!)")
        playerReady = true
        
        if currItem!.seekToSeconds.isNaN {
            self.youtubePlayerView.playVideo()
        } else {
            debugPrint("[YOUTUBEPLAYER] seekToSeconds \(currItem!.seekToSeconds)")
            self.youtubePlayerView.seekToSeconds(currItem!.seekToSeconds, allowSeekAhead: true)
        }
    }
    
    func setPlaying() {
        if !isPlaying {
            isPlaying = true
            self.show(nil)
            
            if !didStart {
                didStart = true
                playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidStart, progress: 0, totalDuration: Double.NaN)
            } else {
                playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: 0, totalDuration: Double.NaN)
            }
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] didChangeToState \(state.rawValue); vid = \(currItem!.native_id!)")
        if state == .Ended {
            debugPrint("[YOUTUBEPLAYER] video ended; vid = \(currItem!.native_id!)")
            if isPlaying {
                isPlaying = false
                playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
            }
        } else if state == .Playing {
            debugPrint("[YOUTUBEPLAYER] video playing; vid = \(currItem!.native_id!)")
            if !playEnabled {
                pauseItem()
                return
            }
        } else if state == .Buffering {
            debugPrint("[YOUTUBEPLAYER] video buffering; playback quality = \(youtubePlayerView.playbackQuality().rawValue); vid = \(currItem!.native_id!)")
            
            isBuffering = true
            
            // playback not yet enabled, pause video
            if !playEnabled {
                pauseItem()
                return
            } else {
                self.bufferingTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(checkForAds), userInfo: nil, repeats: false)
            }
        } else if state == .Unstarted {
            if isBuffering {
                onPlaybackError()
            }
        }
    }
    
    func checkForAds() {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] player State = \(youtubePlayerView.playerState().rawValue); fraction = \(youtubePlayerView.videoLoadedFraction()); playback quality = \(youtubePlayerView.playbackQuality().rawValue); vid = \(currItem!.native_id!)")
        
        // this is a guess of whether ads is showing, based on the way youtube library currently works
        if youtubePlayerView.playerState() == .Buffering && youtubePlayerView.playbackQuality() != .Unknown {
            debugPrint("[YOUTUBEPLAYER] Ads is probably playing... show player; vid = \(currItem!.native_id!)")
            
            // sometimes it just hangs so force to play
            if youtubePlayerView.videoLoadedFraction() < 0.0000001 {
                pauseItem()
                playItem()
            }
            
            setPlaying()
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] didChangeToQuality \(quality.rawValue); vid = \(currItem!.native_id!)")
        
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        if currItem == nil {return}
        let totalDuration = playerView.duration()
        
        setPlaying()
        isBuffering = false
        
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: Double(playTime), totalDuration: totalDuration)
        
        if Int(totalDuration) - Int(playTime) == bufferTimeConstant {
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(endItem), userInfo: nil, repeats: false)
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] receivedError \(error.rawValue); vid = \(currItem!.native_id!)")
        onPlaybackError()
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        return UIColor.clearColor()
    }
}