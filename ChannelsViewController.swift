//
//  ChannelsViewController.swift
//  SmartChannel
//
//  Created by Marc Anderson on 3/6/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol ChannelsViewControllerDelegate: class {
    func channelsView(channelsView: ChannelsViewController, didTapMenuButton: UIBarButtonItem)
    func shouldPresentEditor(sender: ChannelsViewController, withChannel channel: Channel?)
    func shouldPresentPlayer(sender: ChannelsViewController, withChannel channel: Channel)
    func shouldPresentAlert(sender: ChannelsViewController, withAlert alert: UIAlertController, completion: (() -> Void)?)
}

class ChannelsViewController: UIViewController {

    @IBOutlet weak var myChannelsView: UIView!
    @IBOutlet weak var exploreChannelsView: UIView!

    @IBOutlet weak var myChannelsViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var exploreChannelsViewLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var segmentedControl: SegmentedControl!

    var createChannelButton: UIButton!
    private var highlightedColor = Theme.Colors.HighlightColor.color
    private var featuredChannels: [Channel]?
    
    var myChannelsViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            myChannelsViewController.view.frame = myChannelsView.bounds
            myChannelsView.addSubview(myChannelsViewController.view)
        }
    }

    var exploreChannelsViewController: ExploreViewController! {
        didSet {
            view.layoutIfNeeded()
            exploreChannelsViewController.view.frame = exploreChannelsView.bounds
            exploreChannelsView.addSubview(exploreChannelsViewController.view)
            if let featured = featuredChannels {
                exploreChannelsViewController.channels = featured
            }
        }
    }

    weak var delegate: ChannelsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.items = ["My Channels", "Discover"]

        // Push Explore scene off screen to the right
        exploreChannelsViewLeadingConstraint.constant = view.bounds.width

        // Instantiate and add myChannels view controller
        let myChannelsStoryboard = UIStoryboard(name: "MyChannels", bundle: nil)
        let myChannelsVC = myChannelsStoryboard.instantiateViewControllerWithIdentifier("MyChannelsViewController") as! MyChannelsViewController
        myChannelsVC.delegate = self
        myChannelsViewController = myChannelsVC
        addChildViewController(myChannelsViewController)

        setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onValueChanged(sender: SegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // exploreChannelsViewController.willMoveToParentViewController(nil)
            // addChildViewController(myChannelsViewController)
            // myChannelsView.addSubview(myChannelsViewController.view)
            
            view.layer.removeAllAnimations()
            
            self.myChannelsViewTrailingConstraint.constant = self.view.bounds.width
            self.exploreChannelsViewLeadingConstraint.constant = 0
            
            UIView.animateWithDuration(0.4,
                delay: 0,
                options: [.CurveEaseInOut],
                animations: { () -> Void in
                    self.myChannelsViewTrailingConstraint.constant = 0
                    self.exploreChannelsViewLeadingConstraint.constant = self.view.bounds.width
                    self.view.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    //self.exploreChannelsViewController.view.removeFromSuperview()
                    //self.exploreChannelsViewController.removeFromParentViewController()
                    // self.myChannelsViewController.didMoveToParentViewController(self)
                }
            )
        } else {
            // let myc = myChannelsViewController as! MyChannelsViewController
            if exploreChannelsViewController == nil {
                // Instantiate and add Explore view controller
                let exploreStoryboard = UIStoryboard(name: "Explore", bundle: nil)
                let exploreVC = exploreStoryboard.instantiateInitialViewController() as! ExploreViewController
                exploreVC.delegate = self
                exploreChannelsViewController = exploreVC
            }

            // myc.willMoveToParentViewController(nil)
            // addChildViewController(exploreChannelsViewController)
            // exploreChannelsView.addSubview(exploreChannelsViewController.view)
            
            view.layer.removeAllAnimations()
            
            self.myChannelsViewTrailingConstraint.constant = 0
            self.exploreChannelsViewLeadingConstraint.constant = self.view.bounds.width
            
            UIView.animateWithDuration(0.4,
                delay: 0,
                options: [.CurveEaseInOut],
                animations: { () -> Void in
                    self.myChannelsViewTrailingConstraint.constant = self.view.bounds.width
                    self.exploreChannelsViewLeadingConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    // self.myChannelsViewController.view.removeFromSuperview()
                    // self.myChannelsViewController.removeFromParentViewController()
                    // self.exploreChannelsViewController.didMoveToParentViewController(self)
            })
        }
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

// MARK: - MyChannelsViewControllerDelegate

extension ChannelsViewController: MyChannelsViewControllerDelegate {
    func myChannelsVC(sender: MyChannelsViewController, didEditChannel channel: Channel?) {
        if let checkChannel = channel {
            delegate?.shouldPresentEditor(self, withChannel: checkChannel)
        } else {
            delegate?.shouldPresentEditor(self, withChannel: nil)
        }
    }
    func myChannelsVC(sender: MyChannelsViewController, didPlayChannel channel: Channel) {
        delegate?.shouldPresentPlayer(self, withChannel: channel)
    }
    func myChannelsVC(sender: MyChannelsViewController, shouldPresentAlert alert: UIAlertController, completion: (() -> Void)?) {
        delegate?.shouldPresentAlert(self, withAlert: alert, completion: completion)
    }
    func myChannelsVC(sender: MyChannelsViewController, didLoadChannels channels: [Channel]) {
        featuredChannels = channels
    }
    
}

// MARK: - ExploreViewControllerDelegate

extension ChannelsViewController: ExploreViewControllerDelegate {
    func exploreVC(sender: ExploreViewController, didPlayChannel channel: Channel) {
        delegate?.shouldPresentPlayer(self, withChannel: channel)
    }
}

extension ChannelsViewController {
    
    func setupNavigationBar() {
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        createChannelButton = UIButton(type: .System)
        createChannelButton.frame = CGRectMake(0, 0, 40, 40)
        let composeImage = UIImage(named: "icon_add_channel")
        createChannelButton.setImage(composeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        createChannelButton.addTarget(self, action: #selector(createChannelTapped), forControlEvents: UIControlEvents.TouchUpInside)
        createChannelButton.enabled = true
        createChannelButton.tintColor = self.highlightedColor
        
        let createChannelBarButton = UIBarButtonItem(customView: createChannelButton)
        navigationItem.rightBarButtonItems = [negativeSpacer, createChannelBarButton]
        
        let negativeSpacerLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpacerLeft.width = -3
        let createProfileButton = UIButton(type: .System)
        createProfileButton.frame = CGRectMake(0, 0, 20, 20)
        let newImage = UIImage(named: "icon_menu")
        createProfileButton.setImage(newImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        createProfileButton.addTarget(self, action: #selector(profileMenuTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        createProfileButton.tintColor = highlightedColor
        
        let createProfileBarButton = UIBarButtonItem(customView: createProfileButton)
        navigationItem.leftBarButtonItems = [negativeSpacerLeft, createProfileBarButton]
    }
    
    func createChannelTapped() {
        delegate?.shouldPresentEditor(self, withChannel: nil)
    }
    
    func profileMenuTapped(sender: UIBarButtonItem) {
        delegate?.channelsView(self, didTapMenuButton: sender)
    }
    
}
