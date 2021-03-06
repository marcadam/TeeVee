//
//  TweetPlayerView.swift
//  SmartStream
//
//  Created by Hugo Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

let maxNumTweets = 10

class TweetPlayerView: NSObject {
    
    let playerId: String
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView?
    
    private var tableView: UITableView!
    private var currItem: ChannelItem?
    private var items = [ChannelItem]()
    
    private var paused = false
    private var aboutToEndTimer: NSTimer?
    private var endTimer: NSTimer?
    
    init(playerId: String, containerView: UIView?) {
        debugPrint("[TWEETPLAYER] init()")
        
        self.playerId = playerId
        self.playerType = .Tweet
        self.containerView = containerView
        
        super.init()
        tableView = UITableView(frame: containerView!.bounds, style: .Plain)
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        //tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y:  self.tableView.bounds.height)
        tableView.hidden = true
        
        tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        containerView!.addSubview(self.tableView)
    }
    
    deinit {
        debugPrint("[TWEETPLAYER] deinit()")
        currItem = nil
        aboutToEndTimer?.invalidate()
        endTimer?.invalidate()
        aboutToEndTimer = nil
        endTimer = nil
        items.removeAll()
        tableView.removeFromSuperview()
    }
}

extension TweetPlayerView: SmartuPlayer {
    
    func startItem(item: ChannelItem!) {
        debugPrint("[TWEETPLAYER] play next TweetItem")
        
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: 0, totalDuration: 0)
        
        self.tableView.hidden = false
        self.tableView.layer.opacity = 1
        self.currItem = (item.copy() as! ChannelItem)
        
        UIView.beginAnimations("incomingTweet", context: nil)
        UIView.setAnimationDuration(1.2)
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            
        })
        self.tableView.beginUpdates()
        if self.items.count == maxNumTweets {
            let lastIndexPath = NSIndexPath(forRow: self.items.count - 1, inSection: 0)
            self.items.removeLast()
            self.tableView.deleteRowsAtIndexPaths([lastIndexPath], withRowAnimation: .Fade)
        }
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.items.insert(item, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        self.tableView.endUpdates()
        CATransaction.commit()
        UIView.commitAnimations()
        
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, 0)
        
        self.aboutToEndTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(aboutToEndTweet), userInfo: nil, repeats: false)
    }
    
    func aboutToEndTweet() {
        if currItem == nil {return}
        
        debugPrint("[TWEETPLAYER] aboutToEndTweet()")
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
        
        self.endTimer = NSTimer.scheduledTimerWithTimeInterval(fadeOutTimeConstant, target: self, selector: #selector(endTweet), userInfo: nil, repeats: false)
    }
    
    func bufferItem(item: ChannelItem!) {
        
    }
    
    func playItem() {
        if self.paused && currItem != nil {
            self.paused = false
            endTweet()
        }
    }
    
    func pauseItem() {
        aboutToEndTimer?.invalidate()
        endTimer?.invalidate()
        self.paused = true
    }
    
    func stopItem() {
        aboutToEndTimer?.invalidate()
        endTimer?.invalidate()
        self.paused = false
        self.tableView.layer.opacity = 1
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.tableView.layer.opacity = 0
            }, completion: { (bool: Bool) -> Void in
                self.tableView.hidden = true
                self.currItem = nil
                self.items.removeAll()
                self.tableView.reloadData()
                self.endTweet()
        })
    }
    
    func nextItem() {
        
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func getItem() -> ChannelItem? {
        return currItem
    }
    
    func getPlayerId() -> String {
        return playerId
    }
    
    func getPlayerViews() -> [UIView] {
        return [containerView!]
    }
    
    func endTweet() {
        if currItem == nil {return}
        
        if !self.paused {
            debugPrint("[TWEETPLAYER] endTweet()")
            self.playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        }
    }
}

extension TweetPlayerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        if items.count > indexPath.row {
            let channelItem = items[indexPath.row]
            cell.tweet = channelItem.tweet!
        }
        
        return cell
    }
    
    
}