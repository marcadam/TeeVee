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
    @IBOutlet var titleWrapperView: UIView!
    @IBOutlet var searchTextField: UITextField!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleTextField: UITextField!
    
    private var topics:[String] = []
    private var newFilters: Filters?
    private var isEdit = false
    private let bgDarkColor = Theme.Colors.DarkBackgroundColor.color
    private let formTextFont = Theme.Fonts.NormalTypeFace.font
    private let formTextColor = Theme.Colors.HighlightColor.color
    private let formPlaceholderColor = Theme.Colors.HighlightLightColor.color
    
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
        titleWrapperView.backgroundColor = bgDarkColor
        searchWrapperView.backgroundColor = bgDarkColor
        
        titleTextField.font = formTextFont
        searchTextField.font = formTextFont
        
        titleTextField.textColor = formTextColor
        searchTextField.textColor = formTextColor
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Enter a channel title", attributes: [NSForegroundColorAttributeName: formPlaceholderColor])
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Add a new topic", attributes: [NSForegroundColorAttributeName: formPlaceholderColor])
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()
        tableView.rowHeight = 70
        
        let myChannelCellNib = UINib(nibName: "MyChannelTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(myChannelCellNib, forCellReuseIdentifier: "MyChannelTableViewCell")
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
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
                        self.delegate?.channelEditor(self, didSetChannel: channel!)
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
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                searchTextField.text = ""
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

extension ChannelEditorViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FiltersViewDelegate, MyChannelTableViewCellDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyChannelTableViewCell", forIndexPath: indexPath) as! MyChannelTableViewCell
        cell.topicLabel.text = topics[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters) {
        newFilters = filters
    }
    
    func myChannelCell(myChannelCell: MyChannelTableViewCell, didDeleteAt indexPath: NSIndexPath) {
        topics.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
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
