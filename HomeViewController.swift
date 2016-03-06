//
//  HomeViewController.swift
//  SmartStream
//
//  Created by Jerry on 3/5/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    private var contentViewControllers: [UIViewController] = []
    var contentViewController:UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
            }
            
            contentViewController.willMoveToParentViewController(self)
            
            contentViewController.view.frame = contentView.bounds
            contentView.addSubview(contentViewController.view)
            
            contentViewController.didMoveToParentViewController(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add mystream view controller
        guard let myStream = contentViewController as? HomeViewController else {return}
        contentViewControllers.append(myStream)
        
        // Instantiate explore view controller
        let exploreStoryboard = UIStoryboard(name: "Explore", bundle: nil)
        
        // add explore view controller
        guard let explore = exploreStoryboard.instantiateInitialViewController() as? ExploreViewController else {return}
        contentViewControllers.append(explore)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onValueChanged(sender: UISegmentedControl) {
        contentViewController = contentViewControllers[sender.selectedSegmentIndex]
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
