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
    func myChannelsVC(sender: MyChannelsViewController, shouldPresentAlert alert: UIAlertController, completion: (() -> Void)?)
    func myChannelsVC(sender: MyChannelsViewController, shouldEnableAddChannelBtn: Bool)
}

class MyChannelsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createChannelView: UIView!
    @IBOutlet weak var createChannelLabel: UILabel!
    @IBOutlet weak var createChannelButton: UIButton!
    
    let channelCellID = "com.teevee.ChannelTableViewCell"
    
    var containerViewController: HomeViewController!
    
    weak var delegate: MyChannelsViewControllerDelegate?
    
    private var channelsArray: [Channel] = []
    
    var initialOffset: CGFloat? = nil
    var offsetHeaderViewStop: CGFloat!
    var offsetHeader: CGFloat?
    var createChannelButtonOpacity: Float = 1.0
    
    private var highlightColor = Theme.Colors.HighlightColor.color
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let channelCellNib = UINib(nibName: "ChannelTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(channelCellNib, forCellReuseIdentifier: channelCellID)
        tableView.estimatedRowHeight = 67
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Hide empty tableView rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.contentInset = UIEdgeInsets(top: createChannelView.bounds.height, left: 0, bottom: 0, right: 0)
        
        setupUI()
        getChannels()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSTimer.scheduledTimerWithTimeInterval(addBtnFadeDuration, target: self, selector: #selector(toggleFadeIn), userInfo: nil, repeats: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.editing = false
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
    
    @IBAction func didTapCreateNewChannel(sender: UITapGestureRecognizer) {
        delegate?.myChannelsVC(self, didEditChannel: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MyChannelsViewController: UITableViewDataSource, UITableViewDelegate {
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
        let channel = channelsArray[indexPath.row]
        delegate?.myChannelsVC(self, didPlayChannel: channel)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        reorderToTop(channel, toRemove: indexPath)
        
        // Update last_opened timestamp on the backend
        ChannelClient.sharedInstance.updateChannel(channel.channel_id!, channelDict: nil) { (channel, error) -> () in
            if error != nil {
                debugPrint("updateChannel() failed")
                debugPrint("error = \(error.debugDescription)")
            }
        }
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // Play
        let playAction = UITableViewRowAction(style: .Normal, title: " Play    ") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            let channel = self.channelsArray[indexPath.row]
            self.delegate?.myChannelsVC(self, didPlayChannel: channel)
            self.reorderToTop(channel, toRemove: indexPath)
        }
        playAction.backgroundColor = Theme.Colors.PlayColor.color
        
        // Edit
        let editAction = UITableViewRowAction(style: .Normal, title: " Edit    ") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            self.delegate?.myChannelsVC(self, didEditChannel: self.channelsArray[indexPath.row])
        }
        editAction.backgroundColor = Theme.Colors.EditColor.color
        
        // Delete
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            let channel = self.channelsArray[indexPath.row]
            
            let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            let title = NSAttributedString(string: "Delete Channel?", attributes: [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(17),
                NSForegroundColorAttributeName : Theme.Colors.HighlightColor.color
                ]
            )
            alert.setValue(title, forKey: "attributedTitle")
            let message = NSAttributedString(string: "Are you sure you want to delete the \"\(channel.title!)\" channel?", attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName : Theme.Colors.HighlightColor.color
                ]
            )
            alert.setValue(message, forKey: "attributedMessage")
            // Customize UI of alert
            alert.view.tintColor = UIColor.whiteColor()
            let alertSubview = alert.view.subviews.first! as UIView
            let alertContentView = alertSubview.subviews.first! as UIView
            alertContentView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
            alertContentView.layer.cornerRadius = 13
            alertContentView.alpha = 0.8
            
            let alertDeleteAction = UIAlertAction(title: "Delete", style: .Default, handler: { (action) -> Void in
                DataLayer.deleteChannel(withChannelId: channel.channel_id!, completion: { (error, channelId) -> () in
                    self.channelsArray.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        //
                    })
                })
            })
            alert.addAction(alertDeleteAction)
            
            let alertCancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                self.tableView.editing = false
            })
            alert.addAction(alertCancelAction)
            
            self.delegate?.myChannelsVC(self, shouldPresentAlert: alert, completion: { () -> Void in
                // Bugfix: iOS9 - Tint not fully Applied without Reapplying
                alert.view.tintColor = Theme.Colors.HighlightColor.color
            })
            
        }
        deleteAction.backgroundColor = Theme.Colors.DeleteColor.color
        
        return [deleteAction, editAction, playAction]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if initialOffset == nil {
            initialOffset = scrollView.contentOffset.y
        }
        
        if offsetHeaderViewStop == nil {return}
        
        let offset = scrollView.contentOffset.y - initialOffset!
        let newOffset = max(-offsetHeaderViewStop, -offset)
        if offsetHeader == newOffset {
            // already reach maximum offset allowed, do nothing
            return
        }
        
        offsetHeader = newOffset
        //debugPrint("offset = \(offset); offsetHeader = \(offsetHeader)")
        
        createChannelButtonOpacity = 1.0 - Float(offset*4)/100.0
        if createChannelButtonOpacity >= 0 || createChannelButtonOpacity <= 1 {
            createChannelButton.layer.opacity = createChannelButtonOpacity
        }
        
        if createChannelButtonOpacity <= 0 {
            delegate?.myChannelsVC(self, shouldEnableAddChannelBtn: true)
        } else {
            delegate?.myChannelsVC(self, shouldEnableAddChannelBtn: false)
        }
        
        var headerTransform = CATransform3DIdentity
        headerTransform = CATransform3DTranslate(headerTransform, 0, offsetHeader!, 0)
        createChannelView.layer.transform = headerTransform
        
    }
    
}

// MARK: - ChannelEditorDelegate

extension MyChannelsViewController: ChannelEditorDelegate {
    func channelEditor(channelEditor: ChannelEditorViewController, didSetChannel channel: Channel, completion: () -> ()) {
        var channelExist = false
        for (index, arrayChannel) in channelsArray.enumerate() {
            if arrayChannel.channel_id == channel.channel_id {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                reorderToTop(channel, toRemove: indexPath)
                channelExist = true
                break
            }
        }
        
        if !channelExist {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            channelsArray.insert(channel, atIndex: indexPath.row)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        ChannelClient.sharedInstance.updateChannel(channel.channel_id!, channelDict: nil) { (channel, error) -> () in
            if error != nil {
                debugPrint("[update last_opened timestamp")
                debugPrint("error = \(error.debugDescription)")
            }
        }
        
        completion()
    }
    
    func channelEditor(channelEditor: ChannelEditorViewController, didDeleteChannel channelId: String, completion: () -> ()) {
        for (index, arrayChannel) in channelsArray.enumerate() {
            if arrayChannel.channel_id == channelId {
                channelsArray.removeAtIndex(index)
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                break
            }
        }
        completion()
    }
    
    func channelEditor(channelEditor: ChannelEditorViewController, shouldPlayChannel channel: Channel) {
        delegate?.myChannelsVC(self, didPlayChannel: channel)
    }
}

// MARK: - General Functions

extension MyChannelsViewController {
    
    func setupUI() {
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorColor = Theme.Colors.SeparatorColor.color
        
        createChannelView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        createChannelLabel.textColor = highlightColor
        
        offsetHeaderViewStop = createChannelView.bounds.height
        createChannelButton.addTarget(self, action: #selector(createChannelTapped), forControlEvents: UIControlEvents.TouchUpInside)
        createChannelButton.tintColor = highlightColor
    }
    
    func reorderToTop(newChannel: Channel, toRemove indexPath: NSIndexPath) {
        channelsArray.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        channelsArray.insert(newChannel, atIndex: 0)
        let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([topIndexPath], withRowAnimation: .Fade)
    }
    
    func toggleFadeIn() {
        UIView.animateWithDuration(0.3) { () -> Void in
            // set or restore header btn Opacity
            self.createChannelButton.layer.opacity = self.createChannelButtonOpacity
        }
    }
    
    func getChannels() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        ChannelClient.sharedInstance.getMyChannels { (channels, error) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if let channels = channels {
                self.channelsArray = channels
                self.tableView.reloadData()
            }
        }
    }
    
    func createChannelTapped() {
        delegate?.myChannelsVC(self, didEditChannel: nil)
    }

}
