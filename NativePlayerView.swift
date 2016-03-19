//
//  NativePlayerView.swift
//  SmartStream
//
//  Created by Hugo Nguyen on 3/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation

class NativePlayerView: NSObject {
    
    let playerId: Int
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView?
    
    private var nativePlayerView: UIView!
    private var nativePlayerLayer: AVPlayerLayer!
    private var nativePlayerOverlay: UIView!
    
    private let myContext = UnsafeMutablePointer<()>()
    private var nativePlayer: AVQueuePlayer!
    private var timeObserver: AnyObject?
    
    private var currItem: ChannelItem?
    private var isPlaying = false
    
    init(playerId: Int, containerView: UIView?, playerDelegate: SmartuPlayerDelegate?) {
        debugPrint("[NATIVEPLAYER] init()")
        
        self.playerId = playerId
        self.playerType = .Native
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        nativePlayer = AVQueuePlayer()
        nativePlayerView = UIView(frame: containerView!.bounds)
        nativePlayerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        nativePlayerView.backgroundColor = UIColor.clearColor()
        
        nativePlayerLayer = AVPlayerLayer(player: self.nativePlayer)
        nativePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        nativePlayerLayer.frame = containerView!.bounds
        nativePlayerView.layer.addSublayer(nativePlayerLayer)
        nativePlayerLayer.needsDisplayOnBoundsChange = true
        nativePlayerView.layer.needsDisplayOnBoundsChange = true
        containerView!.addSubview(nativePlayerView)
        
        nativePlayerOverlay = UIView(frame: containerView!.bounds)
        nativePlayerOverlay.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        nativePlayerOverlay.backgroundColor = UIColor.blackColor()
        nativePlayerOverlay.alpha = 0.0
        nativePlayerOverlay.userInteractionEnabled = false
        containerView!.addSubview(nativePlayerOverlay)
        
        super.init()
        
        nativePlayer.addObserver(self, forKeyPath: "status", options: [.New], context: self.myContext)
        nativePlayer!.addObserver(self, forKeyPath: "currentItem", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "duration", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "presentationSize", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "error", options: [.New], context: self.myContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nativePlayerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // an observer for every second playback
        timeObserver = nativePlayer!.addPeriodicTimeObserverForInterval(CMTimeMake(1,1), queue: nil, usingBlock: { (time: CMTime) -> Void in
            if self.nativePlayer != nil && self.nativePlayer!.currentItem != nil {
                let currentSecond = self.nativePlayer!.currentItem!.currentTime().value / Int64(self.nativePlayer!.currentItem!.currentTime().timescale)
                let totalDuration = CMTimeGetSeconds(self.nativePlayer!.currentItem!.duration)
                
                if !self.isPlaying {
                    self.isPlaying = true
                    self.show(nil)
                }
                
                playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .Playing, progress: Double(currentSecond), totalDuration: totalDuration)
                
                if totalDuration == totalDuration && Int64(totalDuration) - currentSecond == bufferTimeConstant {
                    self.playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
                    NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "endItem", userInfo: nil, repeats: false)
                }
            }
        })
    }
    
    deinit {
        debugPrint("[NATIVEPLAYER] deinit()")
        if timeObserver != nil {
            nativePlayer.removeTimeObserver(timeObserver!)
        }
        nativePlayer.removeObserver(self, forKeyPath: "status")
        nativePlayer.removeObserver(self, forKeyPath: "currentItem")
        nativePlayer.removeObserver(self, forKeyPath: "duration")
        nativePlayer.removeObserver(self, forKeyPath: "loadedTimeRanges")
        nativePlayer.removeObserver(self, forKeyPath: "presentationSize")
        nativePlayer.removeObserver(self, forKeyPath: "error")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension NativePlayerView: SmartuPlayer {
    func prepareToStart(item: ChannelItem!) {
        
    }
    
    func startItem(item: ChannelItem!) {
        debugPrint("[NATIVEPLAYER] startItem()")
        if item == currItem {return}
        //        nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: currItem)
        //        nativePlayer?.advanceToNextItem()
        dispatch_async(dispatch_get_main_queue(),{
            self.currItem = item.copy() as! ChannelItem
            //nativePlayer?.removeAllItems()
            //debugPrint(item.url!)
            self.nativePlayer.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: nil)
            self.playItem()
        })
    }
    
    func playItem() {
        debugPrint("[NATIVEPLAYER] playItem()")
        nativePlayer.play()
    }
    
    func pauseItem() {
        debugPrint("[NATIVEPLAYER] pauseItem()")
        nativePlayer.pause()
    }
    
    func stopItem() {
        debugPrint("[NATIVEPLAYER] stopItem()")
        currItem = nil
        isPlaying = false
        nativePlayer.pause()
        nativePlayer.replaceCurrentItemWithPlayerItem(nil)
        hide(0.0)
    }
    
    func nextItem() {
        debugPrint("[NATIVEPLAYER] nextItem()")
        //stopItem()
    }
    
    func resetBounds(bounds: CGRect) {
        debugPrint("[NATIVEPLAYER] resetBounds()")
        nativePlayerLayer.frame = bounds
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            //if !nativePlayerView.hidden && nativePlayerOverlay.alpha < 0.1 {return}
            
            debugPrint("[NATIVEPLAYER] fades in native player")
            var du = fadeInTimeConstant
            if duration != nil {
                du = duration!
            }
            self.nativePlayerOverlay.alpha = 1.0
            self.containerView?.bringSubviewToFront(self.nativePlayerView)
            self.containerView?.bringSubviewToFront(self.nativePlayerOverlay)
            UIView.animateWithDuration(du) { () -> Void in
                self.nativePlayerOverlay.alpha = 0.0
            }
        })
    }
    
    func hide(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            debugPrint("[NATIVEPLAYER] fades out native player")
            var du = fadeOutTimeConstant
            if duration != nil {
                du = duration!
            }
            self.nativePlayerOverlay.alpha = 0.0
            UIView.animateWithDuration(du) { () -> Void in
                self.nativePlayerOverlay.alpha = 1.0
            }
        })
    }
    
    func endItem() {
        hide(nil)
    }
    
    func nativePlayerDidFinishPlaying(notification: NSNotification) {
        if isPlaying && nativePlayer.rate != 0 && nativePlayer.error == nil {
            isPlaying = false
            playerDelegate?.playbackStatus(self.playerId, playerType: self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if currItem == nil {return}
        
        if context != myContext {return}
        let nativePlayer = object as? AVPlayer
        if (nativePlayer == nil || nativePlayer! != self.nativePlayer) {return}
        
        if keyPath == "status" {
            
            if self.nativePlayer.status == AVPlayerStatus.ReadyToPlay {
                debugPrint("[NATIVEPLAYER] ready to play")
                self.playItem()
                
            } else if self.nativePlayer.status == AVPlayerStatus.Failed {
                debugPrint("[NATIVEPLAYER] failed to play")
            } else {
                debugPrint("[NATIVEPLAYER] unhandled playerItem status \(self.nativePlayer.status)")
            }
            
        } else if keyPath == "currentItem" {
            
        } else if keyPath == "duration" {
            
            if let timeInterval = self.nativePlayer.currentItem?.duration {
                let totalDuration = CMTimeGetSeconds(timeInterval)
                debugPrint("totalDuration = \(totalDuration)")
            }
            
        } else if keyPath == "loadedTimeRanges" {
        } else if keyPath == "presentationSize" {
        } else if keyPath == "error" {
            
        }
    }
}