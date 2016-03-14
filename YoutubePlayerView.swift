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
    weak var containerView: UIView!
    
    var youtubePlayerView: YTPlayerView!
    var youtubePlayerOverlay: UIView!
    var youtubeWebviewLoaded = false
    
    var currItem: ChannelItem?
    var videoAlreadyCued = false
    
    init(playerId: Int, containerView: UIView!, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerId = playerId
        self.playerType = .Youtube
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        youtubePlayerView = YTPlayerView(frame: containerView.bounds)
        youtubePlayerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        youtubePlayerView.backgroundColor = UIColor.blackColor()
        youtubePlayerView.hidden = true
        containerView.addSubview(self.youtubePlayerView)
        
        youtubePlayerOverlay = UIView(frame: containerView.bounds)
        youtubePlayerOverlay!.backgroundColor = UIColor.blackColor()
        youtubePlayerOverlay!.alpha = 0.0
        youtubePlayerOverlay!.userInteractionEnabled = false
        youtubePlayerView.addSubview(youtubePlayerOverlay!)
        
        super.init()
        youtubePlayerView.delegate = self
    }
    
}


extension YoutubePlayerView: SmartuPlayer {
    
    func prepareYoutubeVideo() {
        self.playItem()
    }
    
    func prepareToStart(item: ChannelItem!) {
        print("[YOUTUBEPLAYER] buffering: extractor = \(item.extractor); id = \(item.native_id)")
        self.youtubePlayerView.cueVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
        videoAlreadyCued = true
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "prepareYoutubeVideo", userInfo: nil, repeats: false)
    }
    
    func startItem(item: ChannelItem!) {
        print("[YOUTUBEPLAYER] play next YoutubeItem")
        if item == currItem {return}
        
        dispatch_async(dispatch_get_main_queue(),{
            
            if !self.youtubeWebviewLoaded {
                self.youtubeWebviewLoaded = true
                self.youtubePlayerView.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
            } else {
                if self.videoAlreadyCued {
                    print("[YOUTUBEPLAYER] YoutubeItem already cued - play now")
                    self.youtubePlayerView.playVideo()
                    self.videoAlreadyCued = false
                } else {
                    self.hide(0.0)
                    self.youtubePlayerView.loadVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
                }
            }
            self.currItem = item
            
        })
    }
    
    func playItem() {
        youtubePlayerView.playVideo()
    }
    
    func stopItem() {
        youtubePlayerView.stopVideo()
    }
    
    func pauseItem() {
        youtubePlayerView.pauseVideo()
    }
    
    func nextItem() {
        
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func show(duration: NSTimeInterval?) {
        //if !youtubePlayerView.hidden && youtubePlayerOverlay.alpha < 0.1 {return}
        
        print("[YOUTUBEPLAYER] fades in youtube player")
        let du = duration == nil ? fadeInTimeConstant: duration!
        self.youtubePlayerOverlay.alpha = 1.0
        self.youtubePlayerView.bringSubviewToFront(self.youtubePlayerOverlay)
        UIView.animateWithDuration(du) { () -> Void in
            self.youtubePlayerOverlay.alpha = 0.0
            self.containerView.bringSubviewToFront(self.youtubePlayerView)
            self.youtubePlayerView.hidden = false
        }
    }
    
    func hide(duration: NSTimeInterval?) {
        print("[YOUTUBEPLAYER] fades out youtube player")
        let du = duration == nil ? fadeOutItmeConstant: duration!
        self.youtubePlayerOverlay.alpha = 0.0
        self.youtubePlayerView.bringSubviewToFront(self.youtubePlayerOverlay)
        UIView.animateWithDuration(du) { () -> Void in
            self.youtubePlayerOverlay.alpha = 1.0
            self.youtubePlayerView.hidden = true
        }
    }
    
}

extension YoutubePlayerView: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("[YOUTUBEPLAYER] playerViewDidBecomeReady")
        self.youtubePlayerView.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("[YOUTUBEPLAYER] didChangeToState \(state.rawValue)")
        if state == .Ended {
            print("[YOUTUBEPLAYER] video ended")
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        } else if state == .Playing {
            print("[YOUTUBEPLAYER] video playing")
            self.show(nil)
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
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print("[YOUTUBEPLAYER] didPlayTime \(error.rawValue)")
        stopItem()
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        return UIColor.whiteColor()
    }
}