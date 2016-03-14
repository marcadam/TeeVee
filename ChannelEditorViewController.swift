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
    private var newFilters: Filters?
    private var isEdit = false
    
    var channel: Channel? {
        didSet {
            if let setChannel = channel {
                isEdit = true
                topics = setChannel.topics!
                view.layoutIfNeeded()
                titleTextField.text = setChannel.title
                if let filters = setChannel.filters {
                    newFilters = filters
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
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Add a new topic", attributes: [NSForegroundColorAttributeName: Theme.Colors.HighlightLightColor.color])
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.rowHeight = 90
    }
    
    func setDefaults() {
        if newFilters == nil {
            // TODO : if this is a new channel, fetch available filters from server
            // ChannelClient.sharedInstance.getAvailableFilters()
            let filtersDict = ["max_duration": 300] as NSDictionary
            newFilters = Filters(dictionary: filtersDict)
        } else {
            // else if this is an existing channel, populate screen/filters using its data
            newFilters = channel!.filters
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
            } else {
                deleteChannel({ (error) -> () in
                    if error != nil {
                        print(error)
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
            destination.filters = newFilters
        } else if segue.identifier == "playerSegue" {
            let destination = segue.destinationViewController as! PlayerViewController
            let channel = sender as! Channel
            destination.channelId = channel.channel_id // substitue with actual channelId
        }
    }
}

extension ChannelEditorViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FiltersViewDelegate {
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
        newFilters = filters
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if let topic = searchTextField.text {
                if topic != "" {
                    topics.insert(topic, atIndex: 0)
                    searchTextField.text = ""
                    tableView.reloadData()
                }
            }
        }
        return true
    }
}

extension ChannelEditorViewController {
    func createChannel(completion: (error: NSError?, channel: Channel?) -> ()) {
        if topics.count > 0 {
            let channelDictionary = ["title": titleTextField.text!, "topics": topics, "filters": newFilters!] as NSDictionary
            DataLayer.createChannel(withDictionary: channelDictionary, completion: { (error, channel) -> () in
                if error != nil {
                    completion(error: error!, channel: nil)
                } else {
                    completion(error: nil, channel: channel!)
                }
            })
        }
    }
    
    func updateChannel(completion: (error: NSError?, channel: Channel?) -> ()) {
        if let channel = channel {
            var count = 0
            var dictionary = [String: AnyObject]()
            
            // set default dictionary items
            dictionary["channel_id"] = channel.channel_id!
            dictionary["topics"] = channel.topics!
            dictionary["title"] = channel.title!
            dictionary["filters"] = channel.filters!
            
            if topics != channel.topics! {
                dictionary["topics"] = topics
                count++
            }
            if titleTextField.text != channel.title && titleTextField.text != "" {
                dictionary["title"] = titleTextField.text
                count++
            }
            if newFilters != channel.filters {
                dictionary["filters"] = newFilters
                count++
            }
            if count > 0 {
                DataLayer.updateChannel(withDictionary: dictionary, completion: { (error, channel) -> () in
                    if error != nil {
                        completion(error: error, channel: nil)
                    } else {
                        completion(error: nil, channel: channel)
                    }
                })
            }
        }
    }
    
    func deleteChannel(completion: (error: NSError?) -> ()) {
        DataLayer.deleteChannel(withChannel: channel!, completion: { (error, channelId) -> () in
            if error != nil {
                print(error)
            } else {
                print(channelId)
            }
        })
    }
}
