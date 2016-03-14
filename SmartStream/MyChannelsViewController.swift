//
//  MyChannelsViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

protocol MyChannelsViewControllerDelegate: class {
    func myChannelsVC(sender: MyChannelsViewController, didEditChannel channel: Channel?)
    func myChannelsVC(sender: MyChannelsViewController, didPlayChannel channel: Channel)
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
        tableView.estimatedRowHeight = 67
        tableView.rowHeight = UITableViewAutomaticDimension

        // Hide empty tableView rows
        tableView.tableFooterView = UIView(frame: CGRectZero)

        setupUI()
        getChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.separatorColor = Theme.Colors.HighlightLightColor.color

        createChannelView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        createChannelLabel.textColor = Theme.Colors.HighlightColor.color
    }

    func getChannels() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        ChannelClient.sharedInstance.getMyChannels { (channels, error) -> () in
            if let channels = channels {
                self.channelsArray = channels
                self.tableView.reloadData()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print(error)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            }
        }
    }
    
    @IBAction func didTapCreateNewChannel(sender: UITapGestureRecognizer) {
        delegate?.myChannelsVC(self, didEditChannel: nil)
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
        cell.channel = channel
        cell.selectionStyle = .None
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.myChannelsVC(self, didPlayChannel: channelsArray[indexPath.row])
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let playAction = UITableViewRowAction(style: .Normal, title: "Play") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            self.delegate?.myChannelsVC(self, didPlayChannel: self.channelsArray[indexPath.row])
            self.tableView.editing = false
        }
        playAction.backgroundColor = UIColor(red: 164/255, green: 179/255, blue: 112/255, alpha: 1)
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            self.delegate?.myChannelsVC(self, didEditChannel: self.channelsArray[indexPath.row])
            self.tableView.editing = false
        }
        editAction.backgroundColor = UIColor(red: 113/255, green: 154/255, blue: 175/255, alpha: 1)
        
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            let channel = self.channelsArray[indexPath.row]
            DataLayer.deleteChannel(withChannel: channel, completion: { (error, channelId) -> () in
                self.channelsArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    //
                })
            })
        }
        deleteAction.backgroundColor = UIColor(red: 225/255, green: 79/255, blue: 79/255, alpha: 1)
        
        return [playAction,editAction,deleteAction]
    }
    
    func channelEditor(channelEditor: ChannelEditorViewController, didSetChannel channel: Channel) {
        for (index, arrayChannel) in channelsArray.enumerate() {
            if arrayChannel.channel_id == channel.channel_id {
                channelsArray[index] = channel
            }
        }
        if !channelsArray.contains(channel) {
            channelsArray.append(channel)
        }
        tableView.reloadData()
    }
}
