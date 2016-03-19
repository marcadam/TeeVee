//
//  UINavigationControllerNoRotate.swift
//  SmartStream
//
//  Created by Marc Anderson on 3/18/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class UINavigationControllerNoRotate: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}
