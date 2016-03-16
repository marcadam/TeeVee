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
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    
    var channelManager: ChannelManager!
    var channelTitle: String!
    var channelId: String! = "0"
    var isPlaying = true
    
    let application = UIApplication.sharedApplication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager.playerContainerView = self.playerView
        channelManager.tweetsContainerView = tweetsView
     
        playerView.clipsToBounds = true
        tweetsView.clipsToBounds = true
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()
        channelTitleLabel.text = channelTitle
        channelTitleLabel.textColor = Theme.Colors.HighlightColor.color
        channelTitleLabel.font = Theme.Fonts.BoldNormalTypeFace.font
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        application.statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        application.statusBarHidden = false
        super.viewWillDisappear(animated)
    }
    
    deinit {
        channelManager.stop()
    }
    
    override func viewWillLayoutSubviews() {
        channelManager.updateBounds(playerView, tweetsContainerView: tweetsView)
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.channelManager.play()
        playButton.hidden = true
        pauseButton.hidden = false
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.channelManager.pause()
        playButton.hidden = false
        pauseButton.hidden = true
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        self.channelManager.next()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

