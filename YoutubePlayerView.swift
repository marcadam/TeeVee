//
//  YoutubePlayerView.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubePlayerView: YTPlayerView {
    let youtubePlayerVars : [NSObject : AnyObject] = [
        "playsinline": 1 ,
        "controls": 0,
        "enablejsapi": 1,
        "autohide": 1,
        "autoplay" : 0,
        "modestbranding" : 1
    ]
    
    var playerDelegate: GenericPlayerDelegate?
    var playerType: PlayerType
    var containerView: UIView!
    
    var youtubePlayerOverlay: UIView!
    var youtubeWebviewLoaded = false
    
    var currItem: ChannelItem?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(playerType: PlayerType, containerView: UIView!, playerDelegate: GenericPlayerDelegate?) {
        self.playerType = playerType
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        super.init(frame: containerView.bounds)
        
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.backgroundColor = UIColor.blackColor()
        self.delegate = self
        containerView.addSubview(self)
        
        youtubePlayerOverlay = UIView(frame: self.bounds)
        youtubePlayerOverlay!.backgroundColor = UIColor.blackColor()
        youtubePlayerOverlay!.alpha = 0.0
        youtubePlayerOverlay!.userInteractionEnabled = false
        self.addSubview(youtubePlayerOverlay!)
    }
    
}


extension YoutubePlayerView: GenericPlayer {
    
    func prepareToStart(item: ChannelItem!) {
        self.cueVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
    }
    
    func startItem(item: ChannelItem!) {
        print("[MANAGER] play next YoutubeItem")
        if item == currItem {return}
        
        dispatch_async(dispatch_get_main_queue(),{
            
            if !self.youtubeWebviewLoaded {
                self.youtubeWebviewLoaded = true
                self.loadWithVideoId(item.native_id!, playerVars: self.youtubePlayerVars)
            } else {
                if self.currItem != nil && self.currItem!.extractor != "youtube" {
                    // previous video is not youtube, so the video is already cued in
                    self.playVideo()
                } else {
                    self.loadVideoById(item.native_id!, startSeconds: 0.0, suggestedQuality: .Default)
                }
            }
            self.currItem = item
            
        })
    }
    
    func playItem() {
        self.playVideo()
    }
    
    func stopItem() {
        self.stopVideo()
    }
    
    func pauseItem() {
        self.pauseVideo()
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func show() {
        print("[MANAGER] fades in youtube player")
        self.youtubePlayerOverlay?.alpha = 1.0
        self.bringSubviewToFront(self.youtubePlayerOverlay!)
        UIView.animateWithDuration(fadeInTimeConstant) { () -> Void in
            self.youtubePlayerOverlay?.alpha = 0.0
            self.containerView.bringSubviewToFront(self)
            self.hidden = false
        }
    }
    
    func hide() {
        print("[MANAGER] fades out youtube player")
        self.youtubePlayerOverlay?.alpha = 0.0
        self.bringSubviewToFront(self.youtubePlayerOverlay!)
        UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
            self.youtubePlayerOverlay?.alpha = 1.0
        }
    }
    
}

extension YoutubePlayerView: YTPlayerViewDelegate, GenericPlayerDelegate {
    
    func playbackStatus(playerType: PlayerType, status: PlaybackStatus, progress: Double, totalDuration: Double) {
        
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("[YOUTUBEPLAYER] playerViewDidBecomeReady")
        self.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("[YOUTUBEPLAYER] didChangeToState \(state.rawValue)")
        if state == .Ended {
            print("[YOUTUBEPLAYER] video ended")
            playerDelegate?.playbackStatus(self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        } else if state == .Playing {
            print("[YOUTUBEPLAYER] video playing")
            self.show()
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
            playerDelegate?.playbackStatus(self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print("[YOUTUBEPLAYER] didPlayTime \(error.rawValue)")
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        return UIColor.whiteColor()
    }
}