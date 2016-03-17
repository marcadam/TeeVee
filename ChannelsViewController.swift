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

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var segmentedControl: SegmentedControl!

    private var contentViewControllers: [UIViewController] = []
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
        }
    }

    var delegate: ChannelsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.items = ["My Streams", "Explore"]

        // Instantiate and add myChannels view controller
        let myChannelsStoryboard = UIStoryboard(name: "MyChannels", bundle: nil)
        let myChannelsVC = myChannelsStoryboard.instantiateViewControllerWithIdentifier("MyChannelsViewController") as! MyChannelsViewController
        myChannelsVC.delegate = self
        contentViewControllers.append(myChannelsVC)

        // Instantiate and add Explore view controller
        let exploreStoryboard = UIStoryboard(name: "Explore", bundle: nil)
        let exploreVC = exploreStoryboard.instantiateInitialViewController() as! ExploreViewController
        exploreVC.delegate = self
        contentViewControllers.append(exploreVC)

        contentViewController = myChannelsVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMenu(sender: UIBarButtonItem) {
        delegate?.channelsView(self, didTapMenuButton: sender)
    }

    @IBAction func onValueChanged(sender: SegmentedControl) {
        contentViewController = contentViewControllers[sender.selectedSegmentIndex]

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
}

// MARK: - ExploreViewControllerDelegate

extension ChannelsViewController: ExploreViewControllerDelegate {
    func exploreVC(sender: ExploreViewController, didPlayChannel channel: Channel) {
        delegate?.shouldPresentPlayer(self, withChannel: channel)
    }
}
