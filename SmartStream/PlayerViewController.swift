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
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var mediaOverlayView: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var landscapeHeaderView: UIView!
    @IBOutlet weak var mediaDescriptionLabel: UILabel!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tweetFeedIndicator: UIView!
    
    private var playerViewTopConstantPortrait: CGFloat!
    private var playerViewTopConstantLandscape: CGFloat!
    
    var channelTitle: String!
    var channelId: String! = "0"
    private var channelManager: ChannelManager?
    
    private var controlsHidden = false
    private var latestTimer: NSTimer?
    private var isPortrait = true
    private var isPlay = false
    private var isTweetPlay = false
    
    private var startGesturePoint: CGPoint?
    private var showingViews: [UIView]?
    
    private let normalBoldFont = Theme.Fonts.BoldNormalTypeFace.font
    private let backgroundColor = Theme.Colors.BackgroundColor.color
    private let highlightColor = Theme.Colors.HighlightColor.color
    private let application = UIApplication.sharedApplication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        playerView.autoresizesSubviews = true
        tweetsView.autoresizesSubviews = true
        playerView.clipsToBounds = true
        tweetsView.clipsToBounds = true
        spinnerView.backgroundColor = UIColor.clearColor()
        
        progressView.trackTintColor = Theme.Colors.LightBackgroundColor.color
        progressView.progressTintColor = highlightColor
        progressView.setProgress(0, animated: false)
        
        tweetFeedIndicator.layer.cornerRadius = tweetFeedIndicator.bounds.height/2
        tweetFeedIndicator.backgroundColor = Theme.Colors.PlayColor.color
        
        let buttonTweetTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTweetTap))
        tweetFeedIndicator.addGestureRecognizer(buttonTweetTapGestureRecognizer)
        
        view.backgroundColor = backgroundColor
        channelTitleLabel.text = channelTitle
        channelTitleLabel.textColor = highlightColor
        channelTitleLabel.font = normalBoldFont
        
        gradientView.colors = [UIColor.clearColor(), backgroundColor]
        gradientView.layer.opacity = 1
        
        dismissButton.tintColor = highlightColor
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onSwipe))
        mediaOverlayView.addGestureRecognizer(panGestureRecognizer)
        
        let mediaTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onMediaTap))
        mediaOverlayView.addGestureRecognizer(mediaTapGestureRecognizer)
        
        let tweetTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTweetTap))
        gradientView.addGestureRecognizer(tweetTapGestureRecognizer)
        
        isPortrait = application.statusBarOrientation.isPortrait
        
        playerViewTopConstantLandscape = 0
        playerViewTopConstantPortrait = topHeaderView.bounds.height
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        landscapeHeaderView.backgroundColor = backgroundColor
        landscapeHeaderView.hidden = true
        
        descriptionView.backgroundColor = backgroundColor
        descriptionView.layer.opacity = 0
        mediaTitleLabel.textColor = highlightColor
        mediaTitleLabel.font = normalBoldFont
        mediaDescriptionLabel.textColor = highlightColor
        
        setTimerToFadeOut()
        setupChannel()
    }
    
    func setupChannel() {
        channelManager = ChannelManager(channelId: channelId, autoplay: true)
        channelManager!.delegate = self
        channelManager!.playerContainerView = playerView
        channelManager!.tweetsContainerView = tweetsView
        channelManager!.spinnerContainerView = spinnerView
        playerViewTopConstraint.constant = getPlayerTopConstant()
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
            tweetFeedIndicator.hidden = false
            if controlsHidden {
                channelTitleLabel.layer.opacity = 0.3
            }
        } else {
            debugPrint("Landscape")
            gradientView.hidden = true
            tweetFeedIndicator.hidden = true
            if controlsHidden {
                channelTitleLabel.layer.opacity = 0
            }
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
        playerViewTopConstraint.constant = getPlayerTopConstant()
        channelManager?.updateBounds(playerView, tweetsContainerView: tweetsView)
    }
    
    func getPlayerTopConstant() -> CGFloat! {
        if application.statusBarOrientation.isPortrait {
            return playerViewTopConstantPortrait
        } else {
            return playerViewTopConstantLandscape
        }
    }
    
    func onSwipe(sender: UIPanGestureRecognizer) {
        if let topViews = showingViews {
            // overlay
            let playView = topViews[0]
            // smartu player
            let playViewOverlay = topViews[1]
            let viewCenterX = view.center.x
            let translation = sender.translationInView(view)
            
            let velocity = sender.velocityInView(view)
            let swipeAwayLeft = velocity.x <= -1000 ? true : false
            
            if sender.state == .Began {
                startGesturePoint = translation
            } else if sender.state == .Changed {
                let deltaX = translation.x - startGesturePoint!.x
                if deltaX < 0 {
                    playViewOverlay.center.x = viewCenterX + deltaX
                    playView.center.x = viewCenterX + deltaX
                }
            } else if sender.state == .Ended {
                if swipeAwayLeft || playView.center.x <= 0 {
                    UIView.animateWithDuration(0.1, animations: {
                        playViewOverlay.center.x = -(viewCenterX)
                        playView.center.x = -(viewCenterX)
                        }, completion: { (finished) in
                            self.progressView.setProgress(0, animated: false)
                            self.channelManager?.next()
                            self.setTimerToFadeOut()
                            
                            if self.descriptionView.hidden == false {
                                UIView.animateWithDuration(0.3, animations: {
                                    self.landscapeHeaderView.layer.opacity = 0
                                    self.descriptionView.layer.opacity = 0
                                    }, completion: { (finished) in
                                        self.descriptionView.hidden = true
                                        self.landscapeHeaderView.hidden = true
                                        self.isPlay = !self.isPlay
                                })
                            }
                            
                    })
                } else {
                    UIView.animateWithDuration(0.1, animations: {
                        playViewOverlay.center.x = viewCenterX
                        playView.center.x = viewCenterX
                    })
                }
            }
        }
    }
    
    func onMediaTap(sender: UITapGestureRecognizer) {
        guard let manager = channelManager else { return }
        if isPlay {
            manager.play()
            UIView.animateWithDuration(0.3, animations: {
                self.landscapeHeaderView.layer.opacity = 0
                self.descriptionView.layer.opacity = 0
                }, completion: { (finished) in
                    self.descriptionView.hidden = true
                    self.landscapeHeaderView.hidden = true
            })
        } else {
            manager.pause()
            self.descriptionView.hidden = false
            self.landscapeHeaderView.hidden = false
            UIView.animateWithDuration(0.3, animations: {
                self.descriptionView.layer.opacity = 0.95
                self.landscapeHeaderView.layer.opacity = 0.95
            })
        }
        animateFadeIn()
        isPlay = !isPlay
    }
    
    func onTweetTap(sender: UITapGestureRecognizer) {
        guard let manager = channelManager else { return }
        
        tweetFeedIndicator.layer.removeAllAnimations()
        
        if isTweetPlay {
            tweetFeedIndicator.backgroundColor = Theme.Colors.DeleteColor.color
            manager.playTweet()
            UIView.animateWithDuration(0.1, animations: {
                // self.tweetFeedIndicator.layer.opacity = 0
                self.tweetFeedIndicator.transform = CGAffineTransformMakeScale(0.01, 1)
                }, completion: { (finished) in
                    self.tweetFeedIndicator.backgroundColor = Theme.Colors.PlayColor.color
                    UIView.animateWithDuration(0.1, animations: {
                        // self.tweetFeedIndicator.layer.opacity = 1
                        self.tweetFeedIndicator.transform = CGAffineTransformMakeScale(1, 1)
                    })
            })
        } else {
            tweetFeedIndicator.backgroundColor = Theme.Colors.PlayColor.color
            manager.pauseTweet()
            UIView.animateWithDuration(0.1, animations: {
                self.tweetFeedIndicator.transform = CGAffineTransformMakeScale(0.01, 1)
                }, completion: { (finished) in
                    self.tweetFeedIndicator.backgroundColor = Theme.Colors.DeleteColor.color
                    UIView.animateWithDuration(0.1, animations: {
                        self.tweetFeedIndicator.transform = CGAffineTransformMakeScale(1, 1)
                    })
            })
        }
        isTweetPlay = !isTweetPlay
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        channelManager?.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onBackgroundTapped(sender: UITapGestureRecognizer) {
        if controlsHidden {
            animateFadeIn()
        } else {
            animateFadeOut()
        }
    }
    
    func setTimerToFadeOut() {
        if let timer = latestTimer {
            timer.invalidate()
        }
        latestTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(animateFadeOut), userInfo: nil, repeats: false)
    }
    
    func animateFadeIn() {
        controlsHidden = false
        dismissButton.layer.removeAllAnimations()
        channelTitleLabel.layer.removeAllAnimations()
        progressView.layer.removeAllAnimations()
        UIView.animateWithDuration(0.5) {
            // show everything
            self.dismissButton.hidden = false
            self.progressView.hidden = false
            self.dismissButton.layer.opacity = 1
            self.channelTitleLabel.layer.opacity = 1
            self.progressView.layer.opacity = 1
            self.setTimerToFadeOut()
        }
    }
    
    func animateFadeOut() {
        UIView.animateWithDuration(0.5, animations: {
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
        }) { (finished) in
            // hide everything
            self.dismissButton.hidden = true
            self.progressView.hidden = true
            self.controlsHidden = true
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
    
    func channelManager(channelManager: ChannelManager, didStartChannelItem item: ChannelItem, withViews views: [UIView]) {
        mediaTitleLabel.text = item.title ?? ""
        mediaDescriptionLabel.text = item.desc ?? ""
        showingViews = views
    }
}

