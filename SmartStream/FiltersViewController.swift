//
//  FiltersViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol FiltersViewDelegate: class {
    func filtersView(filtersView: FiltersViewController, didSetFilters filters: Filters)
}

class FiltersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var filters: Filters! {
        didSet {
            durationSelected = filters.max_duration
            setDurationSelectIndex(durationSelected)
        }
    }
    
    weak var delegate: FiltersViewDelegate?
    private let filterCellID = "com.smartchannel.FilterSwitchCell"
    private let filterSelectCellID = "com.smartchannel.FilterSelectCell"
    private let filterData = ["Max Duration": ["Short < 1 min","Medium < 5 min","Long > 5 min"]]
    private var titles = []
    private var durationSelected: Int!
    private var durationSelectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titles = Array(filterData.keys)
        
        let filterSelectCellNib = UINib(nibName: "FilterSelectCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(filterSelectCellNib, forCellReuseIdentifier: filterSelectCellID)
        
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color

        // Hide empty tableView rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
        filters.max_duration = durationSelected
        filters.updateDictionary(ofKey: "max_duration", withValue: durationSelected)
        self.delegate?.filtersView(self, didSetFilters: filters)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDurationSelectIndex(duration: Int) {
        if duration <= 60 {
            durationSelectedIndex = 0
        } else if duration <= 300 {
            durationSelectedIndex = 1
        } else {
            durationSelectedIndex = 2
        }
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section] as? String
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData["Max Duration"]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(filterSelectCellID, forIndexPath: indexPath) as! FilterSelectCell
        cell.filterCheckImageView.hidden = true
        cell.filterCheckImageView.alpha = 0
        if durationSelectedIndex == indexPath.row {
            UIView.animateWithDuration(1, animations: { () -> Void in
                cell.filterCheckImageView.hidden = false
                cell.filterCheckImageView.alpha = 1
            })
        }
        cell.filterLabel.text = filterData["Max Duration"]![indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            durationSelected = 60
            durationSelectedIndex = 0
        case 1:
            durationSelected = 300
            durationSelectedIndex = 1
        case 2:
            durationSelected = 10000
            durationSelectedIndex = 2
        default:
            durationSelected = 300
            durationSelectedIndex = 1
        }
        tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Theme.Colors.DarkBackgroundColor.color
        header.textLabel?.font = Theme.Fonts.NormalTypeFace.font
        header.textLabel?.textColor = Theme.Colors.HighlightColor.color
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
