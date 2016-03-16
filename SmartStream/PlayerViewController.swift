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
    @IBOutlet weak var tweetsView: UIView!
    
    var channelManager: ChannelManager!
    var channelId: String! = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager.playerContainerView = self.playerView
        channelManager.tweetsContainerView = tweetsView
     
        playerView.clipsToBounds = true
        tweetsView.clipsToBounds = true
    }
    
    deinit {
        channelManager.stop()
    }
    
    override func viewWillLayoutSubviews() {
        channelManager.updateBounds(playerView, tweetsContainerView: tweetsView)
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

