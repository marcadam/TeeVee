//
//  StreamManager.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation
import youtube_ios_player_helper

class StreamManager: NSObject {
    let youtubePlayerVars : [NSObject : AnyObject] = [ "playsinline": 1 , "autoplay" : 1 ]
    let myContext = UnsafeMutablePointer<()>()
    
    var stream: Stream? {
        didSet {
            // Process items, determine which player is needed per item
            if stream == nil || stream!.items.count == 0 {return}
            
            let item = stream!.items[0]
            let extractor = item.extractor
            print("extractor = \(extractor!); id = \(item.id!)")
            
            if extractor == "youtube" {
                playYoutubeItem(item)
            } else {
                playNativeItem(item)
            }
        }
    }
    
    func playYoutubeItem(item: StreamItem!) {
        dispatch_async(dispatch_get_main_queue(),{
            self.youtubePlayerView?.loadWithVideoId(item.id!, playerVars: self.youtubePlayerVars)
        })
    }
    
    func playNativeItem(item: StreamItem!) {
        nativePlayer?.insertItem(AVPlayerItem(URL: NSURL(string: item.url!)!), afterItem: nil)
    }
    
    var nativePlayer: AVQueuePlayer?
    var nativePlayerLayer: AVPlayerLayer?
    var nativePlayerView: UIView?
    var youtubePlayerView: YTPlayerView?
    var webView: UIView?
    
    // Option 1: native player
    var playerContainerView: UIView? {
        didSet {
            if playerContainerView == nil {return}
            nativePlayerView = UIView(frame: playerContainerView!.bounds)
            nativePlayerView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            nativePlayerLayer!.frame = nativePlayerView!.bounds
            nativePlayerView!.layer.addSublayer(nativePlayerLayer!)
            playerContainerView!.addSubview(nativePlayerView!)
            
            youtubePlayerView = YTPlayerView(frame: playerContainerView!.bounds)
            youtubePlayerView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            youtubePlayerView!.delegate = self
            playerContainerView!.addSubview(youtubePlayerView!)
        }
    }
    
    override init() {
        super.init()
        setupAVPlayer()
    }
    
    deinit {
        self.nativePlayer?.pause()
        self.nativePlayer?.removeObserver(self, forKeyPath: "status")
    }
    
    func setupAVPlayer() {
        self.nativePlayer = AVQueuePlayer()
        self.nativePlayer!.addObserver(self, forKeyPath: "status", options: [.New,.Old,.Initial], context: self.myContext)
        self.nativePlayerLayer = AVPlayerLayer(player: self.nativePlayer)
    }
    
    func play() {
        
    }
    
    func stop() {
        
    }
    
    func next() {
        
    }
}


// ==========================================================
// Option 1: Use native iOS player
// ==========================================================
extension StreamManager {
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != myContext {return}
        let nativePlayer = object as? AVPlayer
        if (nativePlayer == nil || nativePlayer != self.nativePlayer) {return}
        
        if keyPath == "status" {
            if nativePlayer!.status == AVPlayerStatus.ReadyToPlay {
                print("ready to play")
            } else if nativePlayer!.status == AVPlayerStatus.Failed {
                print("failed to play")
            } else {
                print("unhandled playerItem status \(nativePlayer!.status)")
            }
        }
    }
    
}


// ==========================================================
// Option 2: Use youtube player
// ==========================================================
extension StreamManager: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("youtubePlayer: playerViewDidBecomeReady")
        self.youtubePlayerView?.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("youtubePlayer: didChangeToState \(state.rawValue)")
        if state == .Ended {
            print("youtubePlayer: video ended")
        }
    }
}


// ==========================================================
// Option 3: Use web view player
// ==========================================================
extension StreamManager {
    
}
