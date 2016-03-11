//
//  MyChannelsViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import AFNetworking

protocol MyChannelsViewControllerDelegate: class {
    func shouldPresentEditor(sender: MyChannelsViewController)
    func shouldPresentPlayer(sender: MyChannelsViewController, withChannel channel: Channel)
}

class MyChannelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var createChannelView: UIView!
    @IBOutlet var createChannelLabel: UILabel!

    let channelCellID = "com.smartchannel.ChannelTableViewCell"

    var containerViewController: HomeViewController!

    var delegate: MyChannelsViewControllerDelegate?
    
    private var channelsArray: [Channel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let channelCellNib = UINib(nibName: "ChannelTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(channelCellNib, forCellReuseIdentifier: channelCellID)
        setupUI()
        getChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color
        createChannelView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        createChannelLabel.textColor = Theme.Colors.HighlightColor.color
    }
    func getChannels() {
        ChannelClient.sharedInstance.getMyChannels { (channels, error) -> () in
            if error == nil {
                self.channelsArray.appendContentsOf(channels!)
                self.tableView.reloadData()
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func didTapCreateNewChannel(sender: UITapGestureRecognizer) {
        delegate?.shouldPresentEditor(self)
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyChannelsViewController: UITableViewDataSource, UITableViewDelegate, ChannelEditorDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(channelCellID, forIndexPath: indexPath) as! ChannelTableViewCell
        let channel = channelsArray[indexPath.row]
        cell.channelName.text = channel.title
        if let thumbnail = channel.thumbnail_url {
            cell.channelImageView.setImageWithURL(NSURL(string: thumbnail)!, placeholderImage: UIImage(named: "placeholder"))
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.shouldPresentPlayer(self, withChannel: channelsArray[indexPath.row])
    }
    
    func channelEditor(channelEditor: ChannelEditorViewController, didSetChannel channel: Channel) {
        channelsArray.append(channel)
        tableView.reloadData()
    }
}
