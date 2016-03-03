//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var stream: Stream?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            self.stream = stream
            
            if stream != nil && stream!.items.count > 0 {
                let url = stream!.items[0].url
                print(url!)
            }
        }
    }

}

