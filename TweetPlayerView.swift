//
//  TweetPlayerView.swift
//  SmartStream
//
//  Created by Hugo Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

let maxNumTweets = 20

class TweetPlayerView: NSObject {
    
    let playerId: Int
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView?
    
    var tableView: UITableView!
    var currItem: ChannelItem?
    var items = [ChannelItem]()
    
    init(playerId: Int, containerView: UIView!, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerId = playerId
        self.playerType = .Tweet
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        super.init()
        tableView = UITableView(frame: containerView.bounds, style: .Plain)
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
        containerView.addSubview(self.tableView)
    }
}

extension TweetPlayerView: SmartuPlayer {
    
    func startItem(item: ChannelItem!) {
        print("[TWEETPLAYER] play next TweetItem")
        
        dispatch_async(dispatch_get_main_queue(),{
            
            self.tableView.hidden = false
            self.currItem = item

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
            
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, 0)
            
            NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "aboutToEndTweet", userInfo: nil, repeats: false)
        })
    }
    
    func aboutToEndTweet() {
        if currItem == nil {return}
        
        print("[TWEETPLAYER] aboutToEndTweet()")
        playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
        
        NSTimer.scheduledTimerWithTimeInterval(fadeOutTimeConstant, target: self, selector: "endTweet", userInfo: nil, repeats: false)
    }
    
    func prepareToStart(item: ChannelItem!) {
        
    }
    
    func playItem() {
        
    }
    
    func pauseItem() {
        
    }
    
    func stopItem() {
        dispatch_async(dispatch_get_main_queue(),{
            self.tableView.hidden = true
        })
        currItem = nil
        items.removeAll()
        endTweet()
    }
    
    func nextItem() {
        
    }
    
    func resetBounds(bounds: CGRect) {
        
    }
    
    func endTweet() {
        self.playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        dispatch_async(dispatch_get_main_queue(),{
            
        })
    }
}

extension TweetPlayerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        
        let channelItem = items[indexPath.row]
        cell.tweet = channelItem.tweet!
        
        return cell
    }
    
    
}