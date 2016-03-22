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
    
    @IBOutlet weak var searchWrapperView: UIView!
    @IBOutlet weak var titleWrapperView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var editIcon: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var channelMainActionButton: UIButton!
    
    private var topics:[String] = []
    private var newFilters: Filters?
    private var isEdit = false
    private let bgDarkColor = Theme.Colors.DarkBackgroundColor.color
    private let formTextFont = Theme.Fonts.NormalTypeFace.font
    private let formTextColor = Theme.Colors.HighlightColor.color
    private let formPlaceholderColor = Theme.Colors.HighlightLightColor.color
    private let backgroundColor = Theme.Colors.BackgroundColor.color
    private var keyboardTimer: NSTimer?
    private var latestTitle = "My Awesome Channel"
    private var keyboardInputAccessory: UIView?
    
    var channel: Channel? {
        didSet {
            if let setChannel = channel {
                isEdit = true
                navigationItem.title = "Edit Channel"
                latestTitle = setChannel.title!
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
        setupNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "showFirstResponder", userInfo: nil, repeats: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        titleTextField.resignFirstResponder()
        searchTextField.resignFirstResponder()
        
        if let kTimer = keyboardTimer {
            kTimer.invalidate()
        }
    }
    
    func uiSetup() {
        view.backgroundColor = backgroundColor

        titleWrapperView.backgroundColor = bgDarkColor
        searchWrapperView.backgroundColor = bgDarkColor
        
        titleTextField.font = formTextFont
        searchTextField.font = formTextFont
        
        titleTextField.textColor = formTextColor
        searchTextField.textColor = formTextColor

        titleTextField.text = latestTitle
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Enter a channel title", attributes: [NSForegroundColorAttributeName: formPlaceholderColor])
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Add a topic to this channel", attributes: [NSForegroundColorAttributeName: formPlaceholderColor])

        titleTextField.autocorrectionType = .No
        searchTextField.autocorrectionType = .No

        tableView.backgroundColor = UIColor.clearColor()
        tableView.rowHeight = 70
        tableView.alwaysBounceVertical = false
        
        let myChannelCellNib = UINib(nibName: "MyChannelTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(myChannelCellNib, forCellReuseIdentifier: "MyChannelTableViewCell")
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        editIcon.tintColor = formTextColor
        editIcon.layer.opacity = 0.3

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
    
    func showFirstResponder() {
        searchTextField.becomeFirstResponder()
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
                        debugPrint(error)
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
                        debugPrint(error)
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
                    debugPrint(error)
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
    
    func onSaveTapped(sender: UIButton) {
        buttonAction(false)
    }
    
    func onSaveAndPlayTapped(sender: AnyObject) {
        buttonAction(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //debugPrint(segue.identifier!)
        if segue.identifier == "EditorToFilters" {
            let filtersVC = segue.destinationViewController as! FiltersViewController
            //let filtersVC = filtersNC.topViewController as! FiltersViewController
            filtersVC.delegate = self
            filtersVC.filters = newFilters
        } else if segue.identifier == "playerSegue" {
            let destination = segue.destinationViewController as! PlayerViewController
            let channel = sender as! Channel
            destination.channelId = channel.channel_id // substitue with actual channelId
        }
    }
    
    func configureSaveButtonBarItem() {
        let buttonTitle = isEdit ? "Save" : "Save & Play"
        let buttonAction = isEdit ? "onSaveTapped:" : "onSaveAndPlayTapped:"
//        accessoryView.setTitle(buttonTitle, forState: .Normal)
//        accessoryView.addTarget(self, action: Selector(buttonAction), forControlEvents: .TouchUpInside)
//        accessoryView.titleLabel!.font = Theme.Fonts.TitleBoldTypeFace.font
//        accessoryView.titleLabel!.textColor = formTextColor
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}

// MARK: - Channel Modification Methods

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
                    debugPrint(error)
                    completion(error: error, channelId: nil)
                } else {
                    debugPrint(channelId)
                    completion(error: nil, channelId: channelId)
                }
            })
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChannelEditorViewController: UITableViewDataSource, UITableViewDelegate {
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
    
}

// MARK: - MyChannelTableViewCellDelegate

extension ChannelEditorViewController: MyChannelTableViewCellDelegate {
    func myChannelCell(myChannelCell: MyChannelTableViewCell) {
        let indexPath = tableView.indexPathForCell(myChannelCell)
        topics.removeAtIndex(indexPath!.row)
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

// MARK: - UITextFieldDelegate

extension ChannelEditorViewController: UITextFieldDelegate {
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == titleTextField {
            titleTextField.text = ""
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.editIcon.layer.opacity = 1
            })
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == titleTextField {
            if titleTextField.text != "" {
                latestTitle = titleTextField.text!
            } else {
                titleTextField.text = latestTitle
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.editIcon.layer.opacity = 0.3
            })
        }
    }
}

// MARK: - FiltersViewDelegate

extension ChannelEditorViewController: FiltersViewDelegate {
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters) {
        newFilters = filters
    }
}

extension ChannelEditorViewController {
    func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        navigationItem.leftBarButtonItem = cancelButton

        let saveButtonAction = isEdit ? "onSaveTapped:" : "onSaveAndPlayTapped:"
        let saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: Selector(saveButtonAction))
        navigationItem.rightBarButtonItem = saveButton
    }

    func cancelTapped() {
        dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    func settingsTapped() {
        performSegueWithIdentifier("EditorToFilters", sender: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        animatetextViewWithKeyboard(notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        animatetextViewWithKeyboard(notification)
    }
    
    func animatetextViewWithKeyboard(notification: NSNotification) {
        // change the view's height to accept the size of the keyboard
        let userInfo = notification.userInfo!
        
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        if notification.name == UIKeyboardWillShowNotification {
            let keyHeight = keyboardSize.height // move up
            // self.view.frame = CGRect(x: 0, y: 0, width: originalFrame!.width, height: originalFrame!.height - keyHeight)
            tableviewBottomConstraint.constant = keyHeight
        } else {
            tableviewBottomConstraint.constant = 0
        }
        
        view.setNeedsUpdateConstraints()
        
        let options = UIViewAnimationOptions(rawValue: curve << 16)
        UIView.animateWithDuration(duration, delay: 0, options: options,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}
