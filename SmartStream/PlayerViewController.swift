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
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonsView: UIView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var channelManager: ChannelManager!
    var channelTitle: String!
    var channelId: String! = "0"
    
    var playerViewTopConstantPortraitTwitterOn: CGFloat!
    var playerViewTopConstantPortraitTwitterOff: CGFloat!
    var playerViewTopConstantLandscape: CGFloat!
    var controlsHidden = false
    var latestTimer:NSTimer?
    
    let application = UIApplication.sharedApplication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager.playerContainerView = playerView
        channelManager.tweetsContainerView = tweetsView
        
        let headerHeight = topHeaderView.bounds.height
        playerViewTopConstantLandscape = 0
        playerViewTopConstantPortraitTwitterOn = headerHeight
        playerViewTopConstantPortraitTwitterOff = view.bounds.height/2 - playerView.bounds.height/2
        playerViewTopConstraint.constant = getPlayerTopConstant(self.channelManager.twitterOn)
        
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        channelTitleLabel.text = channelTitle
        channelTitleLabel.textColor = Theme.Colors.HighlightColor.color
        channelTitleLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        
        playerView.clipsToBounds = true
        tweetsView.clipsToBounds = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        setTimerToFadeOut()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        application.statusBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        application.statusBarHidden = false
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func rotated()
    {
        viewWillLayoutSubviews()
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            print("Portrait")
        } else if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            print("Landscape")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        channelManager.stop()
    }
    
    override func viewWillLayoutSubviews() {
        let newTopConstantTwitterOff = view.bounds.height/2 - playerView.bounds.height/2
        if newTopConstantTwitterOff != playerViewTopConstantPortraitTwitterOff {
            playerViewTopConstantPortraitTwitterOff = newTopConstantTwitterOff
            playerViewTopConstraint.constant = getPlayerTopConstant(self.channelManager.twitterOn)
        }
        channelManager.updateBounds(playerView, tweetsContainerView: tweetsView)
    }
    
    func getPlayerTopConstant(twitterOn: Bool) -> CGFloat! {
        if application.statusBarOrientation.isPortrait {
            if twitterOn {
                return playerViewTopConstantPortraitTwitterOn
            } else {
                return playerViewTopConstantPortraitTwitterOff
            }
        } else {
            return playerViewTopConstantLandscape
        }
    }
    
    @IBAction func onTwitterTapped(sender: UIButton) {
        playerViewTopConstraint.constant = getPlayerTopConstant(!self.channelManager.twitterOn)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (bool: Bool) -> Void in
                self.channelManager.twitterOn = !self.channelManager.twitterOn
        })
        
        setTimerToFadeOut()
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.channelManager.play()
        playButton.hidden = true
        pauseButton.hidden = false
        setTimerToFadeOut()
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.channelManager.pause()
        playButton.hidden = false
        pauseButton.hidden = true
        setTimerToFadeOut()
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        self.channelManager.next()
        setTimerToFadeOut()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onBackgroundTapped(sender: UITapGestureRecognizer) {
        animateFade()
    }
    
    func setTimerToFadeOut() {
        if let timer = latestTimer {
            timer.invalidate()
        }
        latestTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "animateFade", userInfo: nil, repeats: false)
    }
    
    func animateFade() {
        bottomButtonsView.layer.removeAllAnimations()
        dismissButton.layer.removeAllAnimations()
        channelTitleLabel.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if self.controlsHidden {
                // show everything
                self.bottomButtonsView.hidden = false
                self.dismissButton.hidden = false
                self.bottomButtonsView.layer.opacity = 1
                self.dismissButton.layer.opacity = 1
                self.channelTitleLabel.layer.opacity = 1
                self.setTimerToFadeOut()
            } else {
                // hide everything
                self.bottomButtonsView.layer.opacity = 0
                self.dismissButton.layer.opacity = 0
                self.channelTitleLabel.layer.opacity = 0.3
                if let timer = self.latestTimer {
                    timer.invalidate()
                }
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

