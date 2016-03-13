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

    let contentViewPeakOffset: CGFloat = 44.0
    var originalContentViewLeftMargin: CGFloat!
    var menuOpen = false

    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuViewController.view.frame = menuView.bounds
            menuView.addSubview(menuViewController.view)
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
}

extension HomeViewController: ChannelsViewControllerDelegate, ProfileViewControllerDelegate, SettingsViewControllerDelegate {
    private func toggleMenu() {
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
        })
    }

    func channelsView(channelsView: ChannelsViewController, didTapMenuButton: UIBarButtonItem) {
        toggleMenu()
    }

    func profileView(profileView: ProfileViewController, didTapMenuButton: UIBarButtonItem) {
        toggleMenu()
    }

    func settingsView(profileView: SettingsViewController, didTapMenuButton: UIBarButtonItem) {
        toggleMenu()
    }

    func shouldPresentEditor(sender: ChannelsViewController, withChannel channel: Channel?) {
        let editorStoryboard = UIStoryboard(name: "ChannelEditor", bundle: nil)
        let editorNC = editorStoryboard.instantiateViewControllerWithIdentifier("ChannelEditorNavigationController") as! UINavigationController
        let editorVC = editorNC.topViewController as! ChannelEditorViewController
        if let myChannelVC = sender.contentViewController as? MyChannelsViewController {
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
        presentViewController(playerVC, animated: true, completion: nil)
    }

}
