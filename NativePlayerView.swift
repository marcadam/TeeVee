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
    
    let playerType: PlayerType
    weak var playerDelegate: SmartuPlayerDelegate?
    weak var containerView: UIView!
    
    let myContext = UnsafeMutablePointer<()>()
    var nativePlayer: AVQueuePlayer!
    var nativePlayerLayer: AVPlayerLayer!
    var nativePlayerView: UIView!
    var nativePlayerOverlay: UIView!
    var timeObserver: AnyObject?
    
    var currItem: ChannelItem?
    
    init(playerType: PlayerType, containerView: UIView!, playerDelegate: SmartuPlayerDelegate?) {
        
        self.playerType = playerType
        self.containerView = containerView
        self.playerDelegate = playerDelegate
        
        nativePlayer = AVQueuePlayer()
        nativePlayerView = UIView(frame: containerView.bounds)
        nativePlayerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        nativePlayerView.backgroundColor = UIColor.blackColor()
        
        nativePlayerLayer = AVPlayerLayer(player: self.nativePlayer)
        nativePlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        nativePlayerLayer.frame = containerView.bounds
        nativePlayerView.layer.addSublayer(nativePlayerLayer)
        nativePlayerLayer.needsDisplayOnBoundsChange = true
        nativePlayerView.layer.needsDisplayOnBoundsChange = true
        containerView.addSubview(nativePlayerView)
        
        nativePlayerOverlay = UIView(frame: nativePlayerView.bounds)
        nativePlayerOverlay.backgroundColor = UIColor.blackColor()
        nativePlayerOverlay.alpha = 0.0
        nativePlayerOverlay.userInteractionEnabled = false
        nativePlayerView!.addSubview(nativePlayerOverlay)
        
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
                let totalDurationStr = String(format: "%.2f", totalDuration)
                //print("[NATIVEPLAYER] progress: \(currentSecond) / \(totalDurationStr) secs")
                
                if totalDuration == totalDuration && Int64(totalDuration) - currentSecond == bufferTimeConstant {
                    self.playerDelegate?.playbackStatus(self.playerType, status: .WillEnd, progress: 0.0, totalDuration: 0.0)
                }
            }
        })
        
        
    }
    
    deinit {
        if timeObserver != nil {
            nativePlayer.removeTimeObserver(timeObserver!)
        }
        self.nativePlayer.removeObserver(self, forKeyPath: "status")
        self.nativePlayer.removeObserver(self, forKeyPath: "currentItem")
        self.nativePlayer.removeObserver(self, forKeyPath: "duration")
        self.nativePlayer.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.nativePlayer.removeObserver(self, forKeyPath: "presentationSize")
        self.nativePlayer.removeObserver(self, forKeyPath: "error")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension NativePlayerView: SmartuPlayer {
    func prepareToStart(item: ChannelItem!) {
        
    }
    
    func startItem(item: ChannelItem!) {
        print("[MANAGER] play next nativeItem")
        if item == currItem {return}
        //        nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: currItem)
        //        nativePlayer?.advanceToNextItem()
        dispatch_async(dispatch_get_main_queue(),{
            self.currItem = item
            //nativePlayer?.removeAllItems()
            //print(item.url!)
            self.nativePlayer.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: nil)
            self.playItem()
        })
    }
    
    func playItem() {
        nativePlayer.play()
    }
    
    func pauseItem() {
        nativePlayer.pause()
    }
    
    func stopItem() {
        nativePlayer.pause()
        nativePlayer.replaceCurrentItemWithPlayerItem(nil)
    }
    
    func resetBounds(bounds: CGRect) {
        nativePlayerLayer.frame = bounds
    }
    
    func show(duration: NSTimeInterval?) {
        print("[MANAGER] fades in native player")
        let du = duration == nil ? fadeInTimeConstant: duration!
        nativePlayerOverlay.alpha = 1.0
        nativePlayerView.bringSubviewToFront(self.nativePlayerOverlay)
        UIView.animateWithDuration(du) { () -> Void in
            self.nativePlayerOverlay.alpha = 0.0
            self.containerView.bringSubviewToFront(self.nativePlayerView)
            self.nativePlayerView.hidden = false
        }
    }
    
    func hide(duration: NSTimeInterval?) {
        print("[MANAGER] fades out native player")
        let du = duration == nil ? fadeOutItmeConstant: duration!
        nativePlayerOverlay.alpha = 0.0
        nativePlayerView.bringSubviewToFront(self.nativePlayerOverlay)
        UIView.animateWithDuration(du) { () -> Void in
            self.nativePlayerOverlay.alpha = 1.0
        }
    }
    
    
    func nativePlayerDidFinishPlaying(notification: NSNotification) {
        if nativePlayer.rate != 0 && nativePlayer.error == nil {
            playerDelegate?.playbackStatus(self.playerType, status: .DidEnd, progress: 0.0, totalDuration: 0.0)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != myContext {return}
        let nativePlayer = object as? AVPlayer
        if (nativePlayer == nil || nativePlayer! != self.nativePlayer) {return}
        
        if keyPath == "status" {
            
            if self.nativePlayer.status == AVPlayerStatus.ReadyToPlay {
                print("[NATIVEPLAYER] ready to play")
                
                if let currentPlayerAsset = self.nativePlayer.currentItem?.asset as? AVURLAsset {
                    if currItem != nil && currItem!.url == currentPlayerAsset.URL.absoluteString {
                        dispatch_async(dispatch_get_main_queue(),{
                            if self.nativePlayer.currentItem != nil {
                                if let videoTrack = self.nativePlayer.currentItem!.asset.tracksWithMediaType(AVMediaTypeVideo).first {
                                    print("naturalSize = \(videoTrack.naturalSize)")
                                    //print("preferredTransform = \(videoTrack.preferredTransform)")
                                }
                            }
                            self.nativePlayer.play()
                        })
                    }
                }
            } else if self.nativePlayer.status == AVPlayerStatus.Failed {
                print("[NATIVEPLAYER] failed to play")
            } else {
                print("[NATIVEPLAYER] unhandled playerItem status \(self.nativePlayer.status)")
            }
            
        } else if keyPath == "currentItem" {
            
        } else if keyPath == "duration" {
            
            if let timeInterval = self.nativePlayer.currentItem?.duration {
                let totalDuration = CMTimeGetSeconds(timeInterval)
                print("totalDuration = \(totalDuration)")
            }
            
        } else if keyPath == "loadedTimeRanges" {
        } else if keyPath == "presentationSize" {
        } else if keyPath == "error" {
            
        }
    }
}