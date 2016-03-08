//
//  ProfileViewController.swift
//  SmartChannel
//
//  Created by Marc Anderson on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
    func profileView(profileView: ProfileViewController, didTapMenuButton: UIBarButtonItem)
}

class ProfileViewController: UIViewController {

    var containerViewController: HomeViewController!
    var delegate: ProfileViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapMenu(sender: UIBarButtonItem) {
        delegate?.profileView(self, didTapMenuButton: sender)
    }

}
