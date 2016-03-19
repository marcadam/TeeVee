//
//  MenuViewController.swift
//  SmartStream
//
//  Created by Jerry on 3/17/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var containerViewController: HomeViewController!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if user == nil {
            user = Mock.NewUser.Tom.user
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
}
