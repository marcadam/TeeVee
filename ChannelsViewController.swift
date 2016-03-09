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
    func shouldPresentPlayerViewController(sender: ChannelsViewController)
}

class ChannelsViewController: UIViewController {

    @IBOutlet var contentView: UIView!

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

        // Instantiate and add myChannels view controller
        let myChannelsStoryboard = UIStoryboard(name: "MyChannels", bundle: nil)
        let myChannelsVC = myChannelsStoryboard.instantiateViewControllerWithIdentifier("MyChannelsViewController") as! MyChannelsViewController
        myChannelsVC.delegate = self
        contentViewControllers.append(myChannelsVC)

        // Instantiate and add Explore view controller
        let exploreStoryboard = UIStoryboard(name: "Explore", bundle: nil)
        let exploreVC = exploreStoryboard.instantiateInitialViewController() as! ExploreViewController
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

    @IBAction func onValueChanged(sender: UISegmentedControl) {
        contentViewController = contentViewControllers[sender.selectedSegmentIndex]
    }
}

extension ChannelsViewController: MyChannelsViewControllerDelegate {
    func shouldPresentPlayerViewController(sender: MyChannelsViewController) {
        delegate?.shouldPresentPlayerViewController(self)
    }
}
