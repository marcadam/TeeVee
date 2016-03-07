//
//  LoginViewController.swift
//  SmartStream
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueHome" {
            let homeVC = segue.destinationViewController as! HomeViewController
            let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
            let streamsStoryboard = UIStoryboard(name: "Streams", bundle: nil)
            let menuNC = menuStoryboard.instantiateViewControllerWithIdentifier("MenuNavigationController") as! UINavigationController
            let menuVC = menuNC.topViewController as! MenuTableViewController

            let streamsNC = streamsStoryboard.instantiateViewControllerWithIdentifier("StreamsNavigationController") as! UINavigationController
            let streamsVC = streamsNC.topViewController as! StreamsViewController
            streamsVC.delegate = homeVC

            menuVC.containerViewController = homeVC
            homeVC.menuViewController = menuNC
            homeVC.contentViewController = streamsNC
        }
    }
}
