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
    
    private var youtubeWebviewLoaded = false
    
    private var currItem: ChannelItem?
    private var videoAlreadyCued = false
    private var currBounds: CGRect
    private var isPlaying = false
    private var isBuffering = false
    
    init(playerId: Int, containerView: UIView?, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerId = playerId
        self.playerType = .Youtube
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        youtubePlayerView = YTPlayerView(frame: containerView!.bounds)
        youtubePlayerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        youtubePlayerView.backgroundColor = UIColor.clearColor()
        containerView!.addSubview(self.youtubePlayerView)
        
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
    
}


extension YoutubePlayerView: SmartuPlayer {
    
    func prepareYoutubeVideo() {
        self.playItem()
    }
    
    func prepareToStart(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] buffering: extractor = \(item.extractor); id = \(item.native_id)")
        self.youtubePlayerView.cueVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
        videoAlreadyCued = true
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareYoutubeVideo", userInfo: nil, repeats: false)
    }
    
    func startItem(item: ChannelItem!) {
        debugPrint("[YOUTUBEPLAYER] startItem()")
        if item == currItem {return}
        
        dispatch_async(dispatch_get_main_queue(),{
            
            if !self.youtubeWebviewLoaded {
                self.youtubeWebviewLoaded = true
                self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
            } else {
                if self.videoAlreadyCued {
                    debugPrint("[YOUTUBEPLAYER] YoutubeItem already cued - play now")
                    self.youtubePlayerView.playVideo()
                    self.videoAlreadyCued = false
                } else {
                    self.youtubePlayerView.loadVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
                }
            }
            self.currItem = item
            
        })
    }
    
    func playItem() {
        debugPrint("[YOUTUBEPLAYER] playItem()")
        youtubePlayerView.playVideo()
    }
    
    func stopItem() {
        debugPrint("[YOUTUBEPLAYER] stopItem()")
        currItem = nil
        youtubePlayerView.stopVideo()
        isBuffering = false
        isPlaying = false
        hide(0.0)
    }
    
    func pauseItem() {
        debugPrint("[YOUTUBEPLAYER] pauseItem()")
        youtubePlayerView.pauseVideo()
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
            youtubePlayerView.webView.frame = bounds
        }
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            //if !youtubePlayerView.hidden && youtubePlayerOverlay.alpha < 0.1 {return}
            
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
            //if !youtubePlayerView.hidden && youtubePlayerOverlay.alpha < 0.1 {return}
            
            debugPrint("[YOUTUBEPLAYER] fades out youtube player")
            var du = fadeOutTimeConstant
            if duration != nil {
                du = duration!
            }
            self.youtubePlayerOverlay.alpha = 0.0
            UIView.animateWithDuration(du) { () -> Void in
                self.youtubePlayerOverlay.alpha = 1.0
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
        debugPrint("[YOUTUBEPLAYER] playerViewDidBecomeReady")
        self.youtubePlayerView.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] didChangeToState \(state.rawValue)")
        if state == .Ended {
            debugPrint("[YOUTUBEPLAYER] video ended")
            if isPlaying {
                isPlaying = false
                playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
            }
        } else if state == .Playing {
            debugPrint("[YOUTUBEPLAYER] video playing")
        } else if state == .Buffering {
            debugPrint("[YOUTUBEPLAYER] video buffering")
            isBuffering = true
        } else if state == .Unstarted {
            if isBuffering {
                onPlaybackError()
            }
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToQuality quality: YTPlaybackQuality) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] didChangeToQuality \(quality.rawValue)")
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        if currItem == nil {return}
        let totalDuration = playerView.duration()
        
        if !isPlaying {
            isPlaying = true
            self.show(nil)
        }
        
        isBuffering = false
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: Double(playTime), totalDuration: totalDuration)
        
        if Int(totalDuration) - Int(playTime) == bufferTimeConstant {
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "endItem", userInfo: nil, repeats: false)
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        if currItem == nil {return}
        debugPrint("[YOUTUBEPLAYER] receivedError \(error.rawValue)")
        onPlaybackError()
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        return UIColor.clearColor()
    }
}