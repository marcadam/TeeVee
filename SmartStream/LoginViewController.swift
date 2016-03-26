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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onLoginTapped(_:)))
        loginBackgroundView.addGestureRecognizer(tapGesture)
        
        loginLabel.font = Theme.Fonts.BoldNormalTypeFace.font
        loginLabel.textColor = Theme.Colors.HighlightColor.color
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.currentUser != nil {
            self.performSegueWithIdentifier("segueHome", sender: User.currentUser!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueHome" {
            let homeVC = segue.destinationViewController as! HomeViewController
            let menuStoryboard = UIStoryboard(name: "MenuView", bundle: nil)
            let channelsStoryboard = UIStoryboard(name: "Channels", bundle: nil)
            let menuVC = menuStoryboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
            
            if let user = sender as? User {
                menuVC.user = user
            }
            
            let channelsNC = channelsStoryboard.instantiateViewControllerWithIdentifier("ChannelsNavigationController") as! UINavigationController
            let channelsVC = channelsNC.topViewController as! ChannelsViewController
            channelsVC.delegate = homeVC
            
            menuVC.containerViewController = homeVC
            homeVC.menuViewController = menuVC
            homeVC.contentViewController = channelsNC
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    func onLoginTapped(sender: UITapGestureRecognizer) {
        User.login(self) { (error) in
            if error != nil {
                self.performSegueWithIdentifier("segueHome", sender: User.currentUser!)
            } else {
                debugPrint("TODO : Display login error")
                debugPrint(error.debugDescription)
            }
        }
    }
}
