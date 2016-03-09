//
//  MyChannelsViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol MyChannelsViewControllerDelegate: class {
    func shouldPresentEditorViewController(sender: MyChannelsViewController)
    func shouldPresentPlayerViewController(sender: MyChannelsViewController)
}

class MyChannelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let channelCellID = "com.smartchannel.ChannelTableViewCell"

    var containerViewController: HomeViewController!

    var delegate: MyChannelsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let channelCellNib = UINib(nibName: "ChannelTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(channelCellNib, forCellReuseIdentifier: channelCellID)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTapCreateNewChannel(sender: UITapGestureRecognizer) {
        delegate?.shouldPresentEditorViewController(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyChannelsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelTableViewCell
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.shouldPresentPlayerViewController(self)
    }
}
