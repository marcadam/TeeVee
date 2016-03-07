//
//  StreamsViewController.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/6/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol StreamsViewControllerDelegate: class {
    func streamsView(streamsView: StreamsViewController, didTapMenuButton: UIBarButtonItem)
}

class StreamsViewController: UIViewController {

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

    var delegate: StreamsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Instantiate and add myStreams view controller
        let myStreamsStoryboard = UIStoryboard(name: "MyStreams", bundle: nil)
        let myStreamsVC = myStreamsStoryboard.instantiateViewControllerWithIdentifier("MyStreamsViewController") as! MyStreamsViewController
        contentViewControllers.append(myStreamsVC)

        // Instantiate and add Explore view controller
        let exploreStoryboard = UIStoryboard(name: "Explore", bundle: nil)
        let exploreVC = exploreStoryboard.instantiateInitialViewController() as! ExploreViewController
        contentViewControllers.append(exploreVC)

        contentViewController = myStreamsVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMenu(sender: UIBarButtonItem) {
        delegate?.streamsView(self, didTapMenuButton: sender)
    }

    @IBAction func onValueChanged(sender: UISegmentedControl) {
        contentViewController = contentViewControllers[sender.selectedSegmentIndex]
    }
}
