//
//  MenuTableViewController.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var containerViewController: HomeViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 0 {
            let streamsStoryboard = UIStoryboard(name: "Streams", bundle: nil)
            let streamsNC = streamsStoryboard.instantiateViewControllerWithIdentifier("StreamsNavigationController") as! UINavigationController
            let streamsVC = streamsNC.topViewController as! StreamsViewController
            streamsVC.delegate = containerViewController
            containerViewController.contentViewController = streamsNC
        } else if indexPath.section == 1 {
            let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let profileNC = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
            let profileVC = profileNC.topViewController as! ProfileViewController
            profileVC.delegate = containerViewController
            profileVC.containerViewController = containerViewController
            containerViewController.contentViewController = profileNC
        } else if indexPath.section == 2 {
            let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingsNC = settingsStoryboard.instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
            let settingsVC = settingsNC.topViewController as! SettingsViewController
            settingsVC.delegate = containerViewController
            settingsVC.containerViewController = containerViewController
            containerViewController.contentViewController = settingsNC
        }
    }
}
