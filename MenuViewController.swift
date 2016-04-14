//
//  MenuViewController.swift
//  SmartStream
//
//  Created by Jerry on 3/17/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Mixpanel

protocol MenuViewControllerDelegate: class {
    func menuView(menuView: MenuViewController, didTapLogout isTapped: Bool)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var containerViewController: HomeViewController!
    var user: User?
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.sharedInstance().track("MenuViewController.viewDidLoad()")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if User.currentUser == nil {
            user = Mock.NewUser.Tom.user
        } else {
            user = User.currentUser
        }
        
        view.backgroundColor = Theme.Colors.LightBackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.alwaysBounceVertical = false
        let midPointY = view.frame.height / 2.5
        let topPadding = UIEdgeInsets(top: midPointY - 60, left: 0, bottom: 0, right: 0)
        tableView.contentInset = topPadding
        
        logoutButton.titleLabel?.font = Theme.Fonts.BoldNormalTypeFace.font
        logoutButton.tintColor = UIColor.whiteColor()
        logoutButton.titleLabel?.textColor = Theme.Colors.HighlightColor.color
    }
    
    override func viewDidAppear(animated: Bool) {
        Mixpanel.sharedInstance().timeEvent("MenuViewController")
    }
    
    override func viewDidDisappear(animated: Bool) {
        Mixpanel.sharedInstance().track("MenuViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("AvatarCell", forIndexPath: indexPath) as! ProfileAvatarCell
            cell.user = user
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
            return cell
        }
    }
    @IBAction func onLogoutTapped(sender: UIButton) {
        Mixpanel.sharedInstance().track("MenuViewController.onLogoutTapped()")
        
        delegate?.menuView(self, didTapLogout: true)
    }
}
