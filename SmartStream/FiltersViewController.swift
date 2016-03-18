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
    private let filterData = [
        "Max Duration": [
            ["Short",  "<", "1 min"],
            ["Medium", "<", "5 min"],
            ["Long",   ">", "5 min"],
        ]
    ]
    private var titles = []
    private var durationSelected: Int!
    private var durationSelectedIndex: Int!
    private var didChangeFilters = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titles = Array(filterData.keys)
        
        let filterSelectCellNib = UINib(nibName: "FilterSelectCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(filterSelectCellNib, forCellReuseIdentifier: filterSelectCellID)
        
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        tableView.backgroundColor = UIColor.clearColor()

        // Hide empty tableView rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.alwaysBounceVertical = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if didChangeFilters {
            let filtersDictionary = ["max_duration": durationSelected] as NSDictionary
            let newFilters = Filters(dictionary: filtersDictionary)
            self.delegate?.filtersView(self, didSetFilters: newFilters)
        }
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
    @IBAction func didTapDone(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
        cell.filterTextLabel.text = filterData["Max Duration"]![indexPath.row][0]
        cell.filterSymbolLabel.text = filterData["Max Duration"]![indexPath.row][1]
        cell.filterMinuteLabel.text = filterData["Max Duration"]![indexPath.row][2]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0:
            durationSelected = 60
            durationSelectedIndex = 0
            checkIfFilterChanged(durationSelected)
        case 1:
            durationSelected = 300
            durationSelectedIndex = 1
            checkIfFilterChanged(durationSelected)
        case 2:
            durationSelected = 10000
            durationSelectedIndex = 2
            checkIfFilterChanged(durationSelected)
        default:
            durationSelected = 300
            durationSelectedIndex = 1
            checkIfFilterChanged(durationSelected)
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
    
    func checkIfFilterChanged(selected: Int) {
        if filters.max_duration! != selected {
            didChangeFilters = true
        } else {
            didChangeFilters = false
        }
    }
}
