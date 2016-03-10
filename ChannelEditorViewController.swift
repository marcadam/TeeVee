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

class ChannelEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterViewDelegate {
    
    @IBOutlet var searchWrapperView: UIView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    private var keywords:[String] = []
    private var filters: Filter!
    
    weak var delegate: ChannelEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        uiSetup()
        setDefaults()
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
        // ChannelClient.sharedInstance.getAvailableFilter()
        
        // else if this is an existing channel, populate screen/filters using its data
        let filterDict = ["sources": ["youtube", "vimeo", "twitter"], "max_duration": 300]
        filters = Filter(dictionary: filterDict)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChannelEditorCell", forIndexPath: indexPath)
        cell.textLabel?.text = keywords[indexPath.row]
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
        let moveItem = keywords[sourceIndexPath.row]
        keywords.removeAtIndex(sourceIndexPath.row)
        keywords.insert(moveItem, atIndex: destinationIndexPath.row)
        tableView.setEditing(false, animated: true)
    }
    
    func filterView(filterView: FilterViewController, didSetFilters filters: Filter) {
        self.filters = filters
    }
    
    @IBAction func onSaveTapped(sender: UIButton) {
        DataLayer.createChannel(keywords, withFilters: filters!) { (channel) -> () in
            self.delegate?.channelEditor(self, didSetChannel: channel)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                //
            })
        }
    }
    
    @IBAction func onBackTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
            //
        }
    }
    
    @IBAction func onKeywordTapped(sender: AnyObject) {
        if let keyword = searchTextField.text {
            if keyword != "" {
                keywords.insert(keyword, atIndex: 0)
                searchTextField.text = ""
                tableView.reloadData()
            }
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

        print(segue.identifier!)
        if segue.identifier == "filterSegue" {
            let destination = segue.destinationViewController as! FilterViewController
            destination.delegate = self
            destination.filters = filters
        } else if segue.identifier == "playerSegue" {
            let destination = segue.destinationViewController as! PlayerViewController
            destination.channelId = "0" // substitue with actual channelId
        }
    }
    
}
