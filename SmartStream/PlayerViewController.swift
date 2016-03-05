//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var stream: Stream?
    private static var myContext = 0
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
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            self.stream = stream
            self.setupPlayer(stream)
        }
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
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.player?.play()
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.player?.pause()
    }
    
    @IBAction func onDismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
}
