//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var stream: Stream?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    
    private static var myContext = 0
    let myContext = UnsafeMutablePointer<()>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            self.stream = stream
            
            if stream != nil && stream!.items.count > 0 {
                let url = stream!.items[0].url
                print(url!)
                
                let urlAsset = AVURLAsset(URL: NSURL(string: url!)!)
                self.playerItem = AVPlayerItem(asset: urlAsset)
                self.playerItem!.addObserver(self, forKeyPath: "status", options: [.New,.Old,.Initial], context: self.myContext)
                
                self.player = AVPlayer(playerItem: self.playerItem!)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer!.frame = self.view.frame
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != myContext {
            return
        }
        
        let playerItem = object as? AVPlayerItem
        if (playerItem == nil || self.player == nil || playerItem != self.player!.currentItem) {
            return
        }
        
        if keyPath == "status" {
            if playerItem!.status == AVPlayerItemStatus.ReadyToPlay {
                print("ready to play")
                
                self.player!.play()
                print("playing...")
            } else if playerItem!.status == AVPlayerItemStatus.Failed {
                print("failed to play")
            } else {
                print("unhandled playerItem status \(playerItem!.status)")
            }
        }
    }

}

