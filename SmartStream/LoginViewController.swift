//
//  LoginViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var loginBackgroundView: UIView!
    @IBOutlet var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        
        loginBackgroundView.backgroundColor = Theme.Colors.LightButtonColor.color
        loginBackgroundView.layer.cornerRadius = 8
        
        loginLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        loginLabel.textColor = Theme.Colors.HighlightColor.color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueHome" {
            let homeVC = segue.destinationViewController as! HomeViewController
            let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
            let channelsStoryboard = UIStoryboard(name: "Channels", bundle: nil)
            let menuNC = menuStoryboard.instantiateViewControllerWithIdentifier("MenuNavigationController") as! UINavigationController
            let menuVC = menuNC.topViewController as! MenuTableViewController

            let channelsNC = channelsStoryboard.instantiateViewControllerWithIdentifier("ChannelsNavigationController") as! UINavigationController
            let channelsVC = channelsNC.topViewController as! ChannelsViewController
            channelsVC.delegate = homeVC

            menuVC.containerViewController = homeVC
            homeVC.menuViewController = menuNC
            homeVC.contentViewController = channelsNC
        }
    }
}
