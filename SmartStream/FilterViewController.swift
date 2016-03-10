//
//  FilterViewController.swift
//  SmartChannel
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: class {
    func filterView(filterView: FilterViewController, didSetFilter filter: Filter)
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var filter: Filter! {
        didSet {
            durationSelected = filter.max_duration
            sourcesSelected = filter.sources
        }
    }
    
    weak var delegate: FilterViewDelegate?
    private let filterCellID = "com.smartchannel.FilterSwitchCell"
    private let filterSelectCellID = "com.smartchannel.FilterSelectCell"
    private let filterData = ["Source" : ["YouTube", "Vimeo", "Twitter"], "Max Duration": ["Short < 1 min","Medium < 5 min","Long > 5 min"]]
    private var titles = []
    private var durationSelected: Int!
    private var sourcesSelected: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titles = Array(filterData.keys)
        
        let filterCellNib = UINib(nibName: "FilterSwitchCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(filterCellNib, forCellReuseIdentifier: filterCellID)
        
        let filterSelectCellNib = UINib(nibName: "FilterSelectCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(filterSelectCellNib, forCellReuseIdentifier: filterSelectCellID)
        
        tableView.backgroundColor = Theme.Colors.BackgroundColor.color
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        filter.sources = sourcesSelected
        filter.max_duration = durationSelected
        self.delegate?.filterView(self, didSetFilter: filter)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section] as? String
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return filterData["Source"]!.count
        case 1: return filterData["Max Duration"]!.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(filterCellID, forIndexPath: indexPath) as! FilterSwitchCell
            cell.delegate = self
            cell.filterLabel.text = filterData["Source"]![indexPath.row]
            if let cellLabel = cell.filterLabel.text?.lowercaseString {
                if sourcesSelected.contains(cellLabel) {
                    cell.filterSwitch.setOn(true, animated: true)
                } else {
                    cell.filterSwitch.setOn(false, animated: true)
                }
            }
        
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(filterSelectCellID, forIndexPath: indexPath) as! FilterSelectCell
            cell.filterCheckImageView.hidden = true
            cell.filterCheckImageView.alpha = 0
            if durationSelected == indexPath.row {
                UIView.animateWithDuration(1, animations: { () -> Void in
                    cell.filterCheckImageView.hidden = false
                    cell.filterCheckImageView.alpha = 1
                })
            }
            cell.filterLabel.text = filterData["Max Duration"]![indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(filterCellID, forIndexPath: indexPath) as! FilterSwitchCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            durationSelected = indexPath.row
            tableView.reloadData()
        }
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

extension FilterViewController: FilterSwitchCellDelegate {
    func filterSwitchCell(filterSwitchCell: FilterSwitchCell, didSwitchOn: Bool) {
        if didSwitchOn == false {
            for (index, source) in sourcesSelected.enumerate() {
                if source == filterSwitchCell.filterLabel.text?.lowercaseString {
                    sourcesSelected.removeAtIndex(index)
                    break
                }
            }
        } else {
            
        }
    }
}
