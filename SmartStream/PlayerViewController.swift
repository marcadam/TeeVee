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
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonsView: UIView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var bottomButtonsWrapperView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextButton: UIButton!
    
    var channelTitle: String!
    var channelId: String! = "0"
    private var channelManager: ChannelManager?
    
    private var playerViewTopConstantPortraitTwitterOn: CGFloat!
    private var playerViewTopConstantPortraitTwitterOff: CGFloat!
    private var playerViewTopConstantLandscape: CGFloat!
    private var controlsHidden = false
    private var latestTimer: NSTimer?
    private var isPortrait = true
    
    let backgroundColor = Theme.Colors.BackgroundColor.color
    let highlightColor = Theme.Colors.HighlightColor.color
    let application = UIApplication.sharedApplication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        playerView.autoresizesSubviews = true
        tweetsView.autoresizesSubviews = true
        playerView.clipsToBounds = true
        tweetsView.clipsToBounds = true
        spinnerView.backgroundColor = UIColor.clearColor()
        
        playerViewTopConstantLandscape = 0
        playerViewTopConstantPortraitTwitterOn = topHeaderView.bounds.height
        playerViewTopConstantPortraitTwitterOff = view.bounds.height/2 - playerView.bounds.height/2
        
        progressView.trackTintColor = Theme.Colors.LightBackgroundColor.color
        progressView.progressTintColor = Theme.Colors.HighlightColor.color
        progressView.setProgress(0, animated: false)
        
        view.backgroundColor = backgroundColor
        channelTitleLabel.text = channelTitle
        channelTitleLabel.textColor = highlightColor
        channelTitleLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        
        bottomButtonsWrapperView.backgroundColor = UIColor.clearColor()
        gradientView.colors = [UIColor.clearColor(), backgroundColor]
        gradientView.layer.opacity = 0
        
        playButton.tintColor = highlightColor
        pauseButton.tintColor = highlightColor
        nextButton.tintColor = highlightColor
        twitterButton.tintColor = highlightColor
        dismissButton.tintColor = highlightColor
        
        isPortrait = application.statusBarOrientation.isPortrait
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        setTimerToFadeOut()
        setupChannel()
    }
    
    func setupChannel() {
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager!.delegate = self
        channelManager!.playerContainerView = playerView
        channelManager!.tweetsContainerView = tweetsView
        channelManager!.spinnerContainerView = spinnerView
        playerViewTopConstraint.constant = getPlayerTopConstant(channelManager!.twitterOn)
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
        if isPortrait == application.statusBarOrientation.isPortrait {return}
        isPortrait = application.statusBarOrientation.isPortrait
        
        if (application.statusBarOrientation.isPortrait) {
            debugPrint("Portrait")
            application.statusBarHidden = true
            gradientView.hidden = false
            twitterButton.enabled = true
        } else {
            debugPrint("Landscape")
            gradientView.hidden = true
            twitterButton.enabled = false
        }
        
        viewWillLayoutSubviews()
        channelManager?.onRotation(application.statusBarOrientation.isPortrait)
    }
    
    deinit {
        debugPrint("[PlayerViewController] deinit()")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        for subview in playerView.subviews {
            subview.removeFromSuperview()
        }
        for subview in tweetsView.subviews {
            subview.removeFromSuperview()
        }
        channelManager = nil
    }
    
    override func viewWillLayoutSubviews() {
        let newTopConstantTwitterOff = view.bounds.height/2 - playerView.bounds.height/2
        if newTopConstantTwitterOff != playerViewTopConstantPortraitTwitterOff {
            playerViewTopConstantPortraitTwitterOff = newTopConstantTwitterOff
            if channelManager != nil {
                playerViewTopConstraint.constant = getPlayerTopConstant(channelManager!.twitterOn)
            }
        }
        channelManager?.updateBounds(playerView, tweetsContainerView: tweetsView)
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
        if channelManager == nil {return}
        playerViewTopConstraint.constant = getPlayerTopConstant(!channelManager!.twitterOn)
        if channelManager!.twitterOn {
            gradientView.layer.opacity = 1
        } else {
            gradientView.layer.opacity = 0
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if self.channelManager == nil {return}
            
            self.view.layoutIfNeeded()
            if self.channelManager!.twitterOn {
                self.gradientView.layer.opacity = 0
            } else {
                self.gradientView.layer.opacity = 1
            }
            }, completion: { (bool: Bool) -> Void in
                self.channelManager!.twitterOn = !self.channelManager!.twitterOn
        })
        
        setTimerToFadeOut()
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.channelManager?.play()
        playButton.enabled = false
        pauseButton.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.playButton.layer.opacity = 0
            self.pauseButton.layer.opacity = 1
            }) { (finished) -> Void in
                self.playButton.hidden = true
                self.pauseButton.enabled = true
                self.setTimerToFadeOut()
        }
        
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.channelManager?.pause()
        pauseButton.enabled = false
        playButton.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.playButton.layer.opacity = 1
            self.pauseButton.layer.opacity = 0
            }) { (finished) -> Void in
                self.pauseButton.hidden = true
                self.playButton.enabled = true
                self.setTimerToFadeOut()
        }
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        progressView.setProgress(0, animated: false)
        self.channelManager?.next()
        self.onPlayTapped(self)
        setTimerToFadeOut()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        channelManager?.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onBackgroundTapped(sender: UITapGestureRecognizer) {
        animateFade()
    }
    
    func setTimerToFadeOut() {
        if let timer = latestTimer {
            timer.invalidate()
        }
        latestTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(animateFade), userInfo: nil, repeats: false)
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
                self.progressView.hidden = false
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
                    self.progressView.hidden = true
                }
                self.controlsHidden = !self.controlsHidden
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }
}

extension PlayerViewController: ChannelManagerDelegate {
    func channelManager(channelManager: ChannelManager, progress: Double, totalDuration: Double) {
        let newProgress:Float = totalDuration.isNaN ? 0.0 : Float(progress/totalDuration)
        progressView.setProgress(newProgress, animated: true)
    }
}

