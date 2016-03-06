//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation
import youtube_ios_player_helper

class PlayerViewController: UIViewController {

    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var stream: Stream?
    var streamManager = StreamManager()
    let myContext = UnsafeMutablePointer<()>()

    // Option 1: Use native iOS player
    var player: AVQueuePlayer?
    var playerLayer: AVPlayerLayer?

    deinit {
        self.player?.pause()
        self.player?.removeObserver(self, forKeyPath: "status")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        loadingLabel.hidden = false
        playButton.hidden = true
        stopButton.hidden = true
        
        youtubePlayerView?.delegate = self
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            self.stream = stream
            self.setupYoutubePlayer(stream!.items[0])
        }
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.player?.play()
        self.youtubePlayerView?.playVideo()
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.player?.pause()
        self.youtubePlayerView?.stopVideo()
    }
}


// ==========================================================
// Option 1: Use native iOS player
// ==========================================================
extension PlayerViewController {
    
    func setupPlayer(stream: Stream?) {
        if stream != nil && stream!.items.count > 0 {
            
            var playerItems = [AVPlayerItem]()
            
            for item in stream!.items {
                let url = item.url
                print(url!)
                let urlAsset = AVURLAsset(URL: NSURL(string: url!)!)
                let playerItem = AVPlayerItem(asset: urlAsset)
                playerItems.append(playerItem)
            }
            
            self.player = AVQueuePlayer(items: playerItems)
            self.player!.addObserver(self, forKeyPath: "status", options: [.New,.Old,.Initial], context: self.myContext)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer!.frame = self.playerView.bounds
            
            self.playerView.layer.addSublayer(self.playerLayer!)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != myContext {
            return
        }
        
        let player = object as? AVPlayer
        if (player == nil || self.player == nil) {
            return
        }
        
        if keyPath == "status" {
            if player!.status == AVPlayerStatus.ReadyToPlay {
                print("ready to play")
                loadingLabel.hidden = true
                playButton.hidden = false
                stopButton.hidden = false
                self.player!.play()
            } else if player!.status == AVPlayerStatus.Failed {
                print("failed to play")
            } else {
                print("unhandled playerItem status \(player!.status)")
            }
        }
    }
    
    @IBAction func onDismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
}


// ==========================================================
// Option 2: Use web view player
// ==========================================================
extension PlayerViewController: YTPlayerViewDelegate {
    
    func setupYoutubePlayer(item: StreamItem?) {
        if item == nil {return}
        
        var id: String?
        if let extractor = item!.extractor {
            if extractor == "youtube" {
                id = item!.id
            }
        }
        
        let playerVars : [NSObject : AnyObject] = [ "playsinline": 1 , "autoplay" : 1 ]
        dispatch_async(dispatch_get_main_queue(), {
            self.youtubePlayerView?.loadWithVideoId(id, playerVars: playerVars)
        })
        
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("playerViewDidBecomeReady")
        loadingLabel.hidden = true
        playButton.hidden = false
        stopButton.hidden = false
        self.youtubePlayerView?.playVideo()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("didChangeToState \(state.rawValue)")
        if state == .Ended {
            print("video ended")
        }
    }
}
