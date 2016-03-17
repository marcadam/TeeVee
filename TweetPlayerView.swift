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
            self.items.append(item)
            if self.items.count == maxNumTweets {
                self.items.removeFirst()
            }
            //let contentOffset = self.tableView.contentOffset
            //self.tableView.reloadData()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.items.count - 1, inSection: 0)], withRowAnimation: .Fade)
            //self.tableView.contentOffset = contentOffset
            self.tableViewScrollToBottom()
            
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
    
    func tableViewScrollToBottom() {
        
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections - 1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: numberOfSections - 1)
                let lastCellRect = self.tableView.rectForRowAtIndexPath(indexPath)
                let lastCell = self.tableView.cellForRowAtIndexPath(indexPath)
                //self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y)
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    //self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: lastCellRect.origin.y)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                })
            }
            
        })
    }
}