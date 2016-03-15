//
//  TweetPlayerView.swift
//  SmartStream
//
//  Created by Hugo Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import TwitterKit

class TweetPlayerView: NSObject {
    
    let playerId: Int
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView!
    
    let twitterClient = TWTRAPIClient()
    var backgroundView: UIView!
    weak var tweetView: TWTRTweetView!
    
    var currItem: ChannelItem?
    
    init(playerId: Int, containerView: UIView!, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerId = playerId
        self.playerType = .Tweet
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        backgroundView = UIView(frame: containerView.bounds)
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.hidden = true
        containerView.addSubview(backgroundView)
    }
}

extension TweetPlayerView: SmartuPlayer {
    
    func startItem(item: ChannelItem!) {
        print("[TWEETPLAYER] play next TweetItem")
        
        dispatch_async(dispatch_get_main_queue(),{
            self.twitterClient.loadTweetWithID(item.native_id!) { tweet, error in
                if let t = tweet {
                    self.tweetView = TWTRTweetView(tweet: t)
                    self.tweetView!.center = CGPointMake(self.backgroundView.bounds.size.width  / 2,
                        self.backgroundView.bounds.size.height / 2)
                    self.tweetView!.theme = .Light
                    self.show(nil)
                    
                    self.backgroundView.addSubview(self.tweetView!)
                    self.backgroundView.bringSubviewToFront(self.tweetView!)
                    NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: "aboutToEndTweet", userInfo: nil, repeats: false)
                    
                } else {
                    print("[TWEETPLAYER] Failed to load Tweet: \(error!.localizedDescription) ; \(error!.debugDescription)")
                }
            }
            
            self.currItem = item
        })
    }
    
    func aboutToEndTweet() {
        if currItem == nil {return}
        
        print("[TWEETPLAYER] aboutToEndTweet()")
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
        hide(nil)
        NSTimer.scheduledTimerWithTimeInterval(fadeOutItmeConstant, target: self, selector: "endTweet", userInfo: nil, repeats: false)
    }
    
    func prepareToStart(item: ChannelItem!) {
        
    }
    
    func playItem() {
        
    }
    
    func pauseItem() {
        
    }
    
    func stopItem() {
        currItem = nil
        hide(nil)
    }
    
    func nextItem() {
        
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            print("[TWEETPLAYER] fades in tweet player")
            self.tweetView?.alpha = 0.0
            UIView.animateWithDuration(fadeInTimeConstant) { () -> Void in
                self.tweetView?.alpha = 1.0
                self.containerView.bringSubviewToFront(self.backgroundView)
                self.backgroundView.hidden = false
                if self.tweetView != nil {
                    self.backgroundView.bringSubviewToFront(self.tweetView!)
                }
            }
        })
    }
    
    func hide(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            print("[TWEETPLAYER] fades out tweet player")
            self.tweetView?.alpha = 1.0
            UIView.animateWithDuration(fadeOutItmeConstant) { () -> Void in
                self.tweetView?.alpha = 0.0
            }
        })
    }
    
    func endTweet() {
        self.playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        self.tweetView?.removeFromSuperview()
    }
}