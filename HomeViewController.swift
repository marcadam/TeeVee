//
//  HomeViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!

    let contentViewPeakOffset: CGFloat = 50.0
    var originalContentViewLeftMargin: CGFloat!
    var menuOpen = false
    var overlayLayer: UIView!
    private let application = UIApplication.sharedApplication()

    var menuViewController: MenuViewController! {
        didSet {
            view.layoutIfNeeded()
            menuViewController.view.frame = menuView.bounds
            menuView.addSubview(menuViewController.view)
            menuViewController.delegate = self
        }
    }

    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }
            
            contentViewController.willMoveToParentViewController(self)
            contentViewController.view.frame = contentView.bounds
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)

            UIView.animateWithDuration(0.3) { () -> Void in
                self.contentViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            menuOpen = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(togglePeak))
        overlayLayer = UIView(frame: CGRectMake(0, 0, 50, view.frame.height))
        overlayLayer.addGestureRecognizer(tapGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showReceivedMessage:",
                                                         name: PushMessageReceivedKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
//        let translation = sender.translationInView(view)
//        let velocity = sender.velocityInView(view)

//        if sender.state == .Began {
//            originalContentViewLeftMargin = contentViewLeadingConstraint.constant
//        } else if sender.state == .Changed {
//            contentViewLeadingConstraint.constant = originalContentViewLeftMargin + translation.x
//        } else if sender.state == .Ended {
//            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                if velocity.x > 0 {
//                    self.contentViewLeadingConstraint.constant = self.view.bounds.width - self.contentViewPeakOffset
//                    self.menuOpen = true
//                } else {
//                    self.contentViewLeadingConstraint.constant = 0
//                    self.menuOpen = false
//                }
//            })
//        }
    }
    
    
    func showReceivedMessage(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            if let aps = info["aps"] as? Dictionary<String, AnyObject> {
                if let alert = aps["alert"] as? Dictionary<String, String> {
                    showAlert(alert["title"]!, message: alert["body"]!)
                }
            }
        } else {
            print("Software failure. Guru meditation.")
        }
    }
    
    func showAlert(title:String, message:String) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                                          message: message, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
            alert.addAction(dismissAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            let alert = UIAlertView.init(title: title, message: message, delegate: nil,
                                         cancelButtonTitle: "Dismiss")
            alert.show()
        }
    }
}

// MARK: - ChannelsViewControllerDelegate

extension HomeViewController: ChannelsViewControllerDelegate {
    func togglePeak() {
        toggleMenu { 
            //
        }
    }
    private func toggleMenu(completion: () -> ()) {
        originalContentViewLeftMargin = contentViewLeadingConstraint.constant
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if self.menuOpen {
                self.contentViewLeadingConstraint.constant = 0
                self.menuOpen = false
                
            } else {
                self.contentViewLeadingConstraint.constant = self.view.frame.size.width - self.contentViewPeakOffset
                self.menuOpen = true
            }
            self.view.layoutIfNeeded()
            self.application.statusBarHidden = self.menuOpen
            completion()
        })
    }

    func channelsView(channelsView: ChannelsViewController, didTapMenuButton: UIBarButtonItem) {
        
        if menuOpen {
            overlayLayer.removeFromSuperview()
        } else {
            channelsView.view.addSubview(overlayLayer)
        }
        
        toggleMenu { () -> () in
            //
        }
    }

    func shouldPresentEditor(sender: ChannelsViewController, withChannel channel: Channel?) {
        let editorStoryboard = UIStoryboard(name: "ChannelEditor", bundle: nil)
        let editorNC = editorStoryboard.instantiateViewControllerWithIdentifier("ChannelEditorNavigationController") as! UINavigationController
        let editorVC = editorNC.topViewController as! ChannelEditorViewController
        if let myChannelVC = sender.myChannelsViewController as? MyChannelsViewController {
            if let checkChannel = channel {
                editorVC.channel = checkChannel
            } else {
                editorVC.channel = nil
            }
            editorVC.delegate = myChannelVC
        }
        presentViewController(editorNC, animated: true, completion: nil)
    }
    
    func shouldPresentPlayer(sender: ChannelsViewController, withChannel channel: Channel) {
        let playerStoryboard = UIStoryboard(name: "Player", bundle: nil)
        let playerVC = playerStoryboard.instantiateViewControllerWithIdentifier("PlayerStoryboard") as! PlayerViewController
        playerVC.channelId = channel.channel_id
        playerVC.channelTitle = channel.title
        presentViewController(playerVC, animated: true, completion: nil)
    }

    func shouldPresentAlert(sender: ChannelsViewController, withAlert alert: UIAlertController, completion: (() -> Void)?) {
        self.presentViewController(alert, animated: true, completion: {
            completion!()
        })
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

// MARK: - ProfileViewControllerDelegate

extension HomeViewController: ProfileViewControllerDelegate {
    func profileView(profileView: ProfileViewController, didTapMenuButton: UIBarButtonItem) {
        toggleMenu { () -> () in
            //
        }
    }
}

// MARK: - SettingsViewControllerDelegate

extension HomeViewController: SettingsViewControllerDelegate {
    func settingsView(profileView: SettingsViewController, didTapMenuButton: UIBarButtonItem) {
        toggleMenu { () -> () in
            //
        }
    }
}

extension HomeViewController: MenuViewControllerDelegate {
    func menuView(menuView: MenuViewController, didTapLogout isTapped: Bool) {
        if isTapped {
            User.logout()
            toggleMenu({ () -> () in
                self.performSelector(#selector(self.delayDismiss), withObject: nil, afterDelay: 0.5)
            })
        }
    }
    
    func delayDismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
