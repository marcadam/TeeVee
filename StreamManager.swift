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
        }
    }
    
    // Option 1: native player
    var avPlayerView: UIView? {
        didSet {
            if avPlayerView == nil {return}
            self.nativePlayerLayer!.frame = self.avPlayerView!.bounds
            self.avPlayerView!.layer.addSublayer(self.nativePlayerLayer!)
        }
    }
    
    var nativePlayer: AVQueuePlayer?
    var nativePlayerLayer: AVPlayerLayer?
    
    // Option 2: youtube player
    var youtubePlayerView: YTPlayerView?
    
    // Option 3: webview
    var webView: UIWebView?
    
    override init() {
        super.init()
        setupAVPlayer()
        setupYoutubePlayer()
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
    
    func setupYoutubePlayer() {
        youtubePlayerView?.delegate = self
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
