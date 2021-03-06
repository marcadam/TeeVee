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
    
    let playerId: String
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var playerContainerView: UIView?
    
    private var nativePlayerView: UIView!
    private var nativePlayerLayer: AVPlayerLayer!
    private var nativePlayerOverlay: UIView!
    
    private let myContext: UnsafeMutablePointer<Void> = nil
    private var nativePlayer: AVPlayer!
    private var timeObserver: AnyObject?
    private var currBounds: CGRect
    
    private var currItem: ChannelItem?
    private var isPlaying = false
    private var playEnabled = false
    private var didStart = false
    
    init(playerId: String, containerView: UIView?) {
        debugPrint("[NATIVEPLAYER] init()")
        
        self.playerId = playerId
        self.playerType = .Native
        self.playerContainerView = containerView
        
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
        
        currBounds = containerView!.bounds
        
        super.init()
        
        nativePlayer.addObserver(self, forKeyPath: "status", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "currentItem", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "duration", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "presentationSize", options: [.New], context: self.myContext)
        nativePlayer.addObserver(self, forKeyPath: "error", options: [.New], context: self.myContext)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NativePlayerView.nativePlayerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        // an observer for every second playback
        timeObserver = nativePlayer!.addPeriodicTimeObserverForInterval(CMTimeMake(1,1), queue: nil, usingBlock: {[weak self] (time: CMTime) -> Void in
            
            if let strongSelf = self {
                if strongSelf.nativePlayer != nil && strongSelf.nativePlayer!.currentItem != nil {
                    if !strongSelf.playEnabled {
                        strongSelf.pauseItem()
                        strongSelf.nativePlayerOverlay.alpha = 1.0
                        return
                    }
                    
                    if !strongSelf.isPlaying {
                        strongSelf.isPlaying = true
                        strongSelf.show(nil)
                    }
                    
                    let currentSecond = CMTimeGetSeconds(strongSelf.nativePlayer!.currentItem!.currentTime())
                    let totalDuration = CMTimeGetSeconds(strongSelf.nativePlayer!.currentItem!.duration)
                    
                    if !strongSelf.didStart {
                        strongSelf.didStart = true
                        strongSelf.playerDelegate?.playbackStatus(strongSelf.playerId, playerType: strongSelf.playerType, status: .DidStart, progress: 0, totalDuration: Double.NaN)
                    } else {
                        strongSelf.playerDelegate?.playbackStatus(strongSelf.playerId, playerType: strongSelf.playerType, status: .Playing, progress: Double(currentSecond), totalDuration: totalDuration)
                    }
                    
                    if totalDuration == totalDuration && Int64(totalDuration) - Int64(currentSecond) == bufferTimeConstant {
                        strongSelf.playerDelegate?.playbackStatus(strongSelf.playerId, playerType: strongSelf.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
                        NSTimer.scheduledTimerWithTimeInterval(2.0, target: strongSelf, selector: #selector(strongSelf.endItem), userInfo: nil, repeats: false)
                    }
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
        nativePlayerView.layer.sublayers = nil
        nativePlayerView.removeFromSuperview()
        nativePlayerOverlay.removeFromSuperview()
    }
}

extension NativePlayerView: SmartuPlayer {
    func bufferItem(item: ChannelItem!) {
        debugPrint("[NATIVEPLAYER] bufferItem(): extractor = \(item.extractor!); vid = \(item.native_id!)")
        
        playEnabled = false
        self.currItem = (item.copy() as! ChannelItem)
        let asset = AVURLAsset(URL: NSURL(string: item.url!)!, options: nil)
        asset.loadValuesAsynchronouslyForKeys(["playable"], completionHandler: { () -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.nativePlayer.replaceCurrentItemWithPlayerItem(AVPlayerItem(asset: asset))
                
                if !item.seekToSeconds.isNaN {
                    self.nativePlayer.seekToTime(CMTimeMakeWithSeconds(Float64(item.seekToSeconds), 1))
                }
            })
        })
    }
    
    func startItem(item: ChannelItem!) {
        debugPrint("[NATIVEPLAYER] startItem(); vid = \(item.native_id!)")
        
        self.currItem = (item.copy() as! ChannelItem)
        let asset = AVURLAsset(URL: NSURL(string: item.url!)!, options: nil)
        asset.loadValuesAsynchronouslyForKeys(["playable"], completionHandler: { () -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.nativePlayer.replaceCurrentItemWithPlayerItem(AVPlayerItem(asset: asset))
                
                if !item.seekToSeconds.isNaN {
                    self.nativePlayer.seekToTime(CMTimeMakeWithSeconds(Float64(item.seekToSeconds), 1))
                }
                self.playItem()
            })
        })
    }
    
    func playItem() {
        
        playEnabled = true
        debugPrint("[NATIVEPLAYER] playItem(); vid = \(currItem!.native_id!)")
        
        self.nativePlayer.play()
    }
    
    func pauseItem() {
        debugPrint("[NATIVEPLAYER] pauseItem()")
        self.nativePlayer.pause()
    }
    
    func stopItem() {
        debugPrint("[NATIVEPLAYER] stopItem()")
        self.currItem = nil
        self.isPlaying = false
        self.nativePlayer.pause()
        self.nativePlayer.replaceCurrentItemWithPlayerItem(nil)
        self.hide(0.0)
    }
    
    func nextItem() {
        debugPrint("[NATIVEPLAYER] nextItem()")
        //stopItem()
    }
    
    func resetBounds(bounds: CGRect) {
        if currBounds == bounds {return}
        currBounds = bounds
        
        debugPrint("[NATIVEPLAYER] resetBounds()")
        self.nativePlayerLayer.frame = bounds
    }
    
    func getItem() -> ChannelItem? {
        return currItem
    }
    
    func getPlayerId() -> String {
        return playerId
    }
    
    func getPlayerViews() -> [UIView] {
        return [nativePlayerView, nativePlayerOverlay]
    }
    
    func show(duration: NSTimeInterval?) {
        dispatch_async(dispatch_get_main_queue(),{
            debugPrint("[NATIVEPLAYER] fades in native player")
            var du = fadeInTimeConstant
            if duration != nil {
                du = duration!
            }
            self.nativePlayerOverlay.alpha = 1.0
            self.playerContainerView?.bringSubviewToFront(self.nativePlayerView)
            self.playerContainerView?.bringSubviewToFront(self.nativePlayerOverlay)
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
            
            NSTimer.scheduledTimerWithTimeInterval(du, target: self, selector: #selector(self.removeViews), userInfo: nil, repeats: false)
        })
    }
    
    func removeViews() {
        self.nativePlayerView.removeFromSuperview()
        self.nativePlayerOverlay.removeFromSuperview()
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
                debugPrint("[NATIVEPLAYER] ready to play; vid = \(currItem!.native_id!); playEnabled = \(self.playEnabled)")
                
                if self.playEnabled {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.playItem()
                    })
                }
                
            } else if self.nativePlayer.status == AVPlayerStatus.Failed {
                debugPrint("[NATIVEPLAYER] failed to play; vid = \(currItem!.native_id!)")
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