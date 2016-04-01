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
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var bottomButtonsWrapperView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var mediaOverlayView: UIView!
    
    var channelTitle: String!
    var channelId: String! = "0"
    private var channelManager: ChannelManager?
    
    private var playerViewTopConstantPortraitTwitterOn: CGFloat!
    private var playerViewTopConstantPortraitTwitterOff: CGFloat!
    private var playerViewTopConstantLandscape: CGFloat!
    private var controlsHidden = false
    private var latestTimer: NSTimer?
    private var isPortrait = true
    private var isPlay = false
    private var isTweetPlay = false
    
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
        
        gradientView.colors = [UIColor.clearColor(), backgroundColor]
        gradientView.layer.opacity = 1
        
        dismissButton.tintColor = highlightColor
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeGestureRecognizer.direction = .Left
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        let mediaTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onMediaTap))
        mediaOverlayView.addGestureRecognizer(mediaTapGestureRecognizer)
        
        let tweetTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTweetTap))
        gradientView.addGestureRecognizer(tweetTapGestureRecognizer)
        
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
    
    func rotated() {
        if isPortrait == application.statusBarOrientation.isPortrait {return}
        isPortrait = application.statusBarOrientation.isPortrait
        
        if (application.statusBarOrientation.isPortrait) {
            debugPrint("Portrait")
            application.statusBarHidden = true
            gradientView.hidden = false
        } else {
            debugPrint("Landscape")
            gradientView.hidden = true
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
    
    func onSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction.rawValue == 2 {
            progressView.setProgress(0, animated: false)
            self.channelManager?.next()
            setTimerToFadeOut()
        }
    }
    
    func onMediaTap(sender: UITapGestureRecognizer) {
        guard let manager = channelManager else { return }
        if isPlay {
            manager.play()
        } else {
            manager.pause()
        }
        animateFade()
        isPlay = !isPlay
    }
    
    func onTweetTap(sender: UITapGestureRecognizer) {
        guard let manager = channelManager else { return }
        if isTweetPlay {
            manager.playTweet()
        } else {
            manager.pauseTweet()
        }
        animateFade()
        isTweetPlay = !isTweetPlay
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
        dismissButton.layer.removeAllAnimations()
        channelTitleLabel.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if self.controlsHidden {
                // show everything
                self.dismissButton.hidden = false
                self.progressView.hidden = false
                self.dismissButton.layer.opacity = 1
                self.channelTitleLabel.layer.opacity = 1
                self.progressView.layer.opacity = 1
                self.setTimerToFadeOut()
            } else {
                // hide everything
                if !self.isPortrait {
                    self.dismissButton.layer.opacity = 0
                    self.channelTitleLabel.layer.opacity = 0
                    self.progressView.layer.opacity = 0
                } else {
                    self.dismissButton.layer.opacity = 0
                    self.channelTitleLabel.layer.opacity = 0.3
                    self.progressView.layer.opacity = 0
                }
                if let timer = self.latestTimer {
                    timer.invalidate()
                }
            }
        }) { (bool: Bool) -> Void in
            if !self.controlsHidden {
                // hide everything
                if !self.isPortrait {
                    self.dismissButton.hidden = true
                    self.progressView.hidden = true
                }
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

