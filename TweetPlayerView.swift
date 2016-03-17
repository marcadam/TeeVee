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
    weak var containerView: UIView?
    
    let twitterClient = TWTRAPIClient()
    var backgroundView: UIView!
    weak var tweetView: TWTRTweetView!
    
    var tableView: UITableView!
    
    var currItem: ChannelItem?
    
    init(playerId: Int, containerView: UIView!, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerId = playerId
        self.playerType = .Tweet
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        backgroundView = UIView(frame: containerView.bounds)
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.hidden = true
        containerView.addSubview(backgroundView)
        
        super.init()
        tableView = UITableView(frame: containerView.bounds, style: UITableViewStyle.Plain)
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TweetCell")
        containerView.addSubview(self.tableView)
    }
}

extension TweetPlayerView: SmartuPlayer {
    
    func startItem(item: ChannelItem!) {
        print("[TWEETPLAYER] play next TweetItem")
        
        dispatch_async(dispatch_get_main_queue(),{
            self.twitterClient.loadTweetWithID(item.native_id!) { tweet, error in
                if let t = tweet {
                    self.tweetView = TWTRTweetView(tweet: t)
                    self.tweetView!.alpha = 0.0
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
        
        hide(fadeOutTimeConstant - 0.2)
        NSTimer.scheduledTimerWithTimeInterval(fadeOutTimeConstant, target: self, selector: "endTweet", userInfo: nil, repeats: false)
    }
    
    func prepareToStart(item: ChannelItem!) {
        
    }
    
    func playItem() {
        
    }
    
    func pauseItem() {
        
    }
    
    func stopItem() {
        currItem = nil
        endTweet()
    }
    
    func nextItem() {
        
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            print("[TWEETPLAYER] fades in tweet player")
            
            var du = fadeInTimeConstant
            if duration != nil {
                du = duration!
            }
            UIView.animateWithDuration(du) { () -> Void in
                self.tweetView?.alpha = 1.0
                self.containerView?.bringSubviewToFront(self.backgroundView)
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
            
            var du = fadeOutTimeConstant
            if duration != nil {
                du = duration!
            }
            UIView.animateWithDuration(du) { () -> Void in
                self.tweetView?.alpha = 0.0
            }
        })
    }
    
    func endTweet() {
        self.playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        self.tweetView?.removeFromSuperview()
    }
}

extension TweetPlayerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath)
        
        return cell
    }
}