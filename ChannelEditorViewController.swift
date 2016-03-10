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
    
    private var topics:[String] = []
    private var filters: Filters!
    
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
    }
    
    func setDefaults() {
        // TODO : if this is a new channel, fetch available filters from server
        // ChannelClient.sharedInstance.getAvailableFilters()
        
        // else if this is an existing channel, populate screen/filters using its data
        let filtersDict = ["sources": ["youtube", "vimeo", "twitter"], "max_duration": 300]
        filters = Filters(dictionary: filtersDict)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveTapped(sender: UIButton) {
        if topics.count > 0 {
            let filtersDictionary = ["topics": topics, "filters": filters] as NSDictionary
            DataLayer.createChannel(withDictionary: filtersDictionary) { (channel) -> () in
                // Show latest added channel on MyFeed using delegate pattern
                self.delegate?.channelEditor(self, didSetChannel: channel)
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    //
                })
            }
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
            destination.channelId = "0" // substitue with actual channelId
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let moveItem = topics[sourceIndexPath.row]
        topics.removeAtIndex(sourceIndexPath.row)
        topics.insert(moveItem, atIndex: destinationIndexPath.row)
        tableView.setEditing(false, animated: true)
    }
    
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters) {
        self.filters = filters
    }
}
