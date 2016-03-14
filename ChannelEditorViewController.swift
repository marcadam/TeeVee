//
//  ChannelEditorViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ChannelEditorDelegate: class {
    func channelEditor(channelEditor: ChannelEditorViewController, didSetChannel channel: Channel, completion: () -> ())
    func channelEditor(channelEditor: ChannelEditorViewController, didDeleteChannel channelId: String, completion: () -> ())
    func channelEditor(channelEditor: ChannelEditorViewController, shouldPlayChannel channel: Channel)
}

class ChannelEditorViewController: UIViewController {
    
    @IBOutlet var searchWrapperView: UIView!
    @IBOutlet var titleWrapperView: UIView!
    @IBOutlet var searchTextField: UITextField!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleTextField: UITextField!
    
    @IBOutlet var saveBgView: UIView!
    @IBOutlet var playBgView: UIView!
    
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
        tableView.alwaysBounceVertical = false
        
        saveBgView.backgroundColor = bgDarkColor
        playBgView.backgroundColor = bgDarkColor
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
    
    func buttonAction(isPlay: Bool) {
        if isEdit {
            if topics.count > 0 {
                updateChannel(isPlay, completion: { (error, channel) -> () in
                    if error != nil {
                        print(error)
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    } else {
                        self.delegate?.channelEditor(self, didSetChannel: channel!, completion: { () -> () in
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.isEdit = false
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                if isPlay {
                                    self.delegate?.channelEditor(self, shouldPlayChannel: channel!)
                                }
                            })
                        })
                    }
                })
            } else {
                deleteChannel({ (error, channelId) -> () in
                    if error != nil {
                        print(error)
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    } else {
                        self.delegate?.channelEditor(self, didDeleteChannel: channelId!, completion: { () -> () in
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.isEdit = false
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                //
                            })
                        })
                    }
                })
            }
        } else {
            createChannel { (error, channel) -> () in
                if error != nil {
                    print(error)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                } else {
                    // Show latest added channel on MyFeed using delegate pattern
                    self.delegate?.channelEditor(self, didSetChannel: channel!, completion: { () -> () in
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            if isPlay {
                                self.delegate?.channelEditor(self, shouldPlayChannel: channel!)
                            }
                        })
                    })
                }
            }
        }
    }
    
    @IBAction func onBackgroundTapped(sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
    }
    
    @IBAction func onSaveTapped(sender: UIButton) {
        buttonAction(false)
    }
    
    @IBAction func onStartChannelTapped(sender: AnyObject) {
        buttonAction(true)
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
    
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters) {
        newFilters = filters
    }
    
    func myChannelCell(myChannelCell: MyChannelTableViewCell) {
        let indexPath = tableView.indexPathForCell(myChannelCell)
        topics.removeAtIndex(indexPath!.row)
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if let topic = searchTextField.text {
                if topic != "" {
                    topics.insert(topic, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    searchTextField.text = ""
                }
            }
        }
        return true
    }
}

extension ChannelEditorViewController {
    func createChannel(completion: (error: NSError?, channel: Channel?) -> ()) {
        if topics.count > 0 {
            MBProgressHUD.showHUDAddedTo(view, animated: true)
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
    
    func updateChannel(isPlay: Bool, completion: (error: NSError?, channel: Channel?) -> ()) {
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
                MBProgressHUD.showHUDAddedTo(view, animated: true)
                DataLayer.updateChannel(withDictionary: dictionary, completion: { (error, channel) -> () in
                    if error != nil {
                        completion(error: error, channel: nil)
                    } else {
                        completion(error: nil, channel: channel)
                    }
                })
            } else {
                dismissViewControllerAnimated(true, completion: { () -> Void in
                    if isPlay {
                        self.delegate?.channelEditor(self, shouldPlayChannel: channel)
                    }
                })
            }
        }
    }
    
    func deleteChannel(completion: (error: NSError?, channelId: String?) -> ()) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        if let channel = channel {
            DataLayer.deleteChannel(withChannelId: channel.channel_id!, completion: { (error, channelId) -> () in
                if error != nil {
                    print(error)
                    completion(error: error, channelId: nil)
                } else {
                    print(channelId)
                    completion(error: nil, channelId: channelId)
                }
            })
        }
    }
}
