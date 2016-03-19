//
//  SettingsViewController.swift
//  SmartChannel
//
//  Created by Marc Anderson on 3/5/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsView(profileView: SettingsViewController, didTapMenuButton: UIBarButtonItem)
}

class SettingsViewController: UIViewController {

    var containerViewController: HomeViewController!
    var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapMenu(sender: UIBarButtonItem) {
        delegate?.settingsView(self, didTapMenuButton: sender)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}
