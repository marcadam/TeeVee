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
        "modestbranding" : 1
    ]
    
    let playerId: Int
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView?
    
    private var youtubePlayerView: YTPlayerView!
    private var youtubePlayerOverlay: UIView!
    
    private var currItem: ChannelItem?
    private var currBounds: CGRect
    private var isPlaying = false
    private var isBuffering = false
    private var bufferingTimer: NSTimer?
    private var playEnabled = false
    
    init(playerId: Int, containerView: UIView?) {
        debugPrint("[YOUTUBEPLAYER] init()")
        
        self.playerId = playerId
        self.playerType = .Youtube
        self.containerView = containerView
        
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
        debugPrint("[YOUTUBEPLAYER] deinit()")
        youtubePlayerView.removeFromSuperview()
        youtubePlayerOverlay.removeFromSuperview()
    }
}


extension YoutubePlayerView: SmartuPlayer {
    
    
    func bufferItem(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] bufferItem(): extractor = \(item.extractor!); id = \(item.native_id!)")
        //self.youtubePlayerView.cueVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
        
        playEnabled = false
        dispatch_async(dispatch_get_main_queue(),{
            self.currItem = (item.copy() as! ChannelItem)
            self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
        })
    }
    
    func startItem(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] startItem()")
        //if item == currItem {return}
        
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
            self.currItem = (item.copy() as! ChannelItem)
        })
    }
    
    func playItem() {
        playEnabled = true
        
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] playItem(); vid = \(currItem!.native_id!)")
        
        self.youtubePlayerView.playVideo()
    }
    
    func stopItem() {
        debugPrint("[YOUTUBEPLAYER] stopItem()")
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
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            debugPrint("[YOUTUBEPLAYER] fades in youtube player")
            var du = fadeInTimeConstant
            if duration != nil {
                du = duration!
            }
            
            self.youtubePlayerOverlay.alpha = 1.0
            self.containerView?.bringSubviewToFront(self.youtubePlayerView)
            self.containerView?.bringSubviewToFront(self.youtubePlayerOverlay)
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
                self.youtubePlayerView.removeFromSuperview()
                self.youtubePlayerOverlay.removeFromSuperview()
            }
        })
    }
    
    func endItem() {
        hide(nil)
    }
    
    func onPlaybackError() {
        debugPrint("[YOUTUBEPLAYER] onPlaybackError()")
        stopItem()
        isBuffering = false
        isPlaying = false
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
    }
}

extension YoutubePlayerView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] playerViewDidBecomeReady; vid = \(currItem!.native_id!)")
        
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
            
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: 0, totalDuration: Double.NaN)
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
        } else if state == .Buffering {
            debugPrint("[YOUTUBEPLAYER] video buffering; playback quality = \(youtubePlayerView.playbackQuality().rawValue); vid = \(currItem!.native_id!)")
            
            if !playEnabled {
                pauseItem()
                return
            }
            
            isBuffering = true
            
            self.bufferingTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(checkForAds), userInfo: nil, repeats: false)
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