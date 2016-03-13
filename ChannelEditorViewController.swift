//
//  ChannelEditorViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol ChannelEditorDelegate: class {
    func channelEditor(channelEditor: ChannelEditorViewController, didSetChannel channel: Channel)
}

class ChannelEditorViewController: UIViewController {
    
    @IBOutlet var searchWrapperView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleTextField: UITextField!
    
    private var topics:[String] = []
    private var filters: Filters?
    private var isEdit = false
    
    var channel: Channel? {
        didSet {
            if let setChannel = channel {
                isEdit = true
                topics = setChannel.topics!
                view.layoutIfNeeded()
                titleTextField.text = setChannel.title ?? nil
                if let filters = setChannel.filters {
                    self.filters = filters
                }
            }
        }
    }
    
    weak var delegate: ChannelEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        uiSetup()
        setDefaults()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func uiSetup() {
        searchWrapperView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        searchTextField.font = Theme.Fonts.TitleThinTypeFace.font
        searchTextField.textColor = Theme.Colors.HighlightColor.color
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Create Channel", attributes: [NSForegroundColorAttributeName: Theme.Colors.HighlightLightColor.color])
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.rowHeight = 100
    }
    
    func setDefaults() {
        // TODO : if this is a new channel, fetch available filters from server
        // ChannelClient.sharedInstance.getAvailableFilters()
        
        // else if this is an existing channel, populate screen/filters using its data
        if filters == nil {
            let filtersDict = ["max_duration": 300] as NSMutableDictionary
            filters = Filters(dictionary: filtersDict)
        } else {
            filters = channel?.filters
        }
    }
    
    func createChannel(completion: (error: NSError?, channel: Channel?)->()) {
        if topics.count > 0 {
            let channelDictionary = ["title": titleTextField.text!, "topics": topics, "filters": filters!] as NSDictionary
            DataLayer.createChannel(withDictionary: channelDictionary, completion: { (error, channel) -> () in
                if error != nil {
                    completion(error: error!, channel: nil)
                } else {
                    completion(error: nil, channel: channel!)
                }
            })
        }
    }
    
    func updateChannel(completion: (error: NSError?, channel: Channel?)->()) {
        if let channel = channel {
            var count = 0
            if topics != channel.topics! {
                channel.topics = topics
                count++
            }
            if titleTextField.text != channel.title && titleTextField.text != "" {
                channel.title = titleTextField.text
                count++
            }
            if filters != channel.filters {
                channel.filters = filters
                count++
            }
            if count > 0 {
                DataLayer.updateChannel(withChannel: channel, completion: { (error, channel) -> () in
                    if error != nil {
                        completion(error: error, channel: nil)
                    } else {
                        completion(error: nil, channel: channel)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveTapped(sender: UIButton) {
        if isEdit {
            if topics.count > 0 {
                updateChannel({ (error, channel) -> () in
                    if error != nil {
                        print(error)
                    } else {
                        self.delegate?.channelEditor(self, didSetChannel: self.channel!)
                    }
                })
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.isEdit = false
                })
            }
        } else {
            createChannel { (error, channel) -> () in
                if error != nil {
                    print(error)
                } else {
                    // Show latest added channel on MyFeed using delegate pattern
                    self.delegate?.channelEditor(self, didSetChannel: channel!)
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        //
                    })
                }
            }
        }
    }
    
    @IBAction func onStartChannelTapped(sender: AnyObject) {
        if topics.count > 0 {
            createChannel({ (error, channel) -> () in
                self.performSegueWithIdentifier("playerSegue", sender: channel!)
            })
        }
    }
    
    @IBAction func onBackTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    @IBAction func onKeywordTapped(sender: AnyObject) {
        if let topic = searchTextField.text {
            if topic != "" {
                topics.insert(topic, atIndex: 0)
                searchTextField.text = ""
                tableView.reloadData()
            }
        }
    }
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print(segue.identifier!)
        if segue.identifier == "filtersSegue" {
            let destination = segue.destinationViewController as! FiltersViewController
            destination.delegate = self
            destination.filters = filters
        } else if segue.identifier == "playerSegue" {
            let destination = segue.destinationViewController as! PlayerViewController
            let channel = sender as! Channel
            destination.channelId = channel.channel_id // substitue with actual channelId
        }
    }
}

extension ChannelEditorViewController: UITableViewDataSource, UITableViewDelegate, FiltersViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelEditorCell", forIndexPath: indexPath)
        cell.textLabel?.text = topics[indexPath.row]
        cell.textLabel?.font = Theme.Fonts.LightNormalTypeFace.font
        cell.textLabel?.textColor = Theme.Colors.HighlightColor.color
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            self.topics.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        deleteAction.backgroundColor = UIColor(red: 225/255, green: 79/255, blue: 79/255, alpha: 1)
        
        return [deleteAction]
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters) {
        self.filters = filters
    }
}
