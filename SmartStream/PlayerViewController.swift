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
    //@IBOutlet weak var tweetsView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonsView: UIView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var channelManager: ChannelManager!
    var channelTitle: String!
    var channelId: String! = "0"
    var isPlaying = true
    var twitterOn = false
    var playerViewTopConstant: CGFloat!
    var controlsHidden = false
    
    let application = UIApplication.sharedApplication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager.playerContainerView = self.playerView
        //channelManager.tweetsContainerView = tweetsView
        
        let viewCenterDistance = view.frame.height/2
        let headerHeight = topHeaderView.frame.height
        playerView.clipsToBounds = true
        playerView.layoutIfNeeded()
        playerViewTopConstant = viewCenterDistance - headerHeight - playerView.frame.height/2
        playerViewTopConstraint.constant = playerViewTopConstant
        //tweetsView.clipsToBounds = true
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()
        channelTitleLabel.text = channelTitle
        channelTitleLabel.textColor = Theme.Colors.HighlightColor.color
        channelTitleLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        tableView.hidden = true
        tableView.separatorStyle = .None
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
        //channelManager.updateBounds(playerView, tweetsContainerView: tweetsView)
    }
    
    @IBAction func onTwitterTapped(sender: UIButton) {
        if twitterOn {
            // Hide Twitter Stream
            playerViewTopConstraint.constant = playerViewTopConstant
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (bool: Bool) -> Void in
                    self.twitterOn = !self.twitterOn
                    self.tableView.hidden = true
            })
        } else {
            // Show Twitter Stream
            playerViewTopConstraint.constant = 0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (bool: Bool) -> Void in
                    self.twitterOn = !self.twitterOn
                    self.tableView.hidden = false
            })
        }
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
    
    @IBAction func onBackgroundTapped(sender: UITapGestureRecognizer) {
        animateFade()
    }
    
    func animateFade() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if self.controlsHidden {
                // show everything
                self.bottomButtonsView.hidden = false
                self.dismissButton.hidden = false
                self.bottomButtonsView.layer.opacity = 1
                self.dismissButton.layer.opacity = 1
                self.channelTitleLabel.layer.opacity = 1
            } else {
                // hide everything
                self.bottomButtonsView.layer.opacity = 0
                self.dismissButton.layer.opacity = 0
                self.channelTitleLabel.layer.opacity = 0.3
            }
            }) { (bool: Bool) -> Void in
                if !self.controlsHidden {
                    // hide everything
                    self.bottomButtonsView.hidden = true
                    self.dismissButton.hidden = true
                }
                self.controlsHidden = !self.controlsHidden
        }
    }
}

