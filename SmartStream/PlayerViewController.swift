//
//  ViewController.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: UIView!
    
    var channelManager: ChannelManager!
    var channelId: String! = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        channelManager = ChannelManager(channelId: channelId)
        channelManager.playerContainerView = self.playerView
        
        ChannelClient.sharedInstance.getChannel(channelId) { (channel, error) -> () in
            if channel != nil {
                self.channelManager.channel = channel
            }
        }
    }
    
    deinit {
        channelManager.stop()
    }
    
    override func viewWillLayoutSubviews() {
        channelManager.updateBounds(self.playerView)
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.channelManager.play()
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.channelManager.pause()
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        self.channelManager.next()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

