//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import Player

class ViewController: UIViewController, PlayerDelegate {

    var stream: Stream?
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.player = Player()
        self.player.delegate = self
        self.player.view.frame = self.view.bounds
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMoveToParentViewController(self)
        
        self.player.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            self.stream = stream
            
            if stream != nil && stream!.items.count > 0 {
                let url = stream!.items[0].url
                print(url!)
                let videoUrl = NSURL(string: url!)
                self.player.setUrl(videoUrl!)
                self.player.playFromBeginning()
            }
        }
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.Stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.Paused.rawValue:
            self.player.playFromCurrentTime()
        case PlaybackState.Playing.rawValue:
            self.player.pause()
        case PlaybackState.Failed.rawValue:
            self.player.pause()
        default:
            self.player.pause()
        }
    }


    
    func playerReady(player: Player) {
        print("playerReady")
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
        print("playerPlaybackWillStartFromBeginning")
    }
    
    func playerPlaybackDidEnd(player: Player) {
        print("playerPlaybackDidEnd")
    }
    
    func playerPlaybackStateDidChange(player: Player) {
        print("playerPlaybackStateDidChange")
    }
    
    func playerBufferingStateDidChange(player: Player) {
        print("playerPlaybackStateDidChange")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

