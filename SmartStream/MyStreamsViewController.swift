//
//  MyStreamsViewController.swift
//  SmartStream
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

protocol MyStreamsViewControllerDelegate: class {
    func myStreamsView(streamsView: MyStreamsViewController, didTapMenuButton: UIBarButtonItem)
}

class MyStreamsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let streamCellID = "com.smartstream.StreamTableViewCell"

    var containerViewController: HomeViewController!
    var delegate: MyStreamsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let streamCellNib = UINib(nibName: "StreamTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(streamCellNib, forCellReuseIdentifier: streamCellID)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapMenu(sender: UIBarButtonItem) {
        delegate?.myStreamsView(self, didTapMenuButton: sender)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyStreamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(streamCellID, forIndexPath: indexPath) as! StreamTableViewCell
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("seguePlayerStoryboard", sender: self)
    }
}
