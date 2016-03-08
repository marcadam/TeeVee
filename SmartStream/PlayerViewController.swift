//
//  ViewController.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var playerView: UIView!
    
    var streamManager = StreamManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        streamManager.playerContainerView = self.playerView
        
        StreamClient.sharedInstance.getStream { (stream, error) -> () in
            if stream != nil {
                self.streamManager.stream = stream
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        streamManager.updateBounds(self.playerView)
    }
    
    @IBAction func onPlayTapped(sender: AnyObject) {
        self.streamManager.play()
    }
    
    @IBAction func onStopTapped(sender: AnyObject) {
        self.streamManager.pause()
    }
    
    @IBAction func onNextTapped(sender: AnyObject) {
        self.streamManager.next()
    }
    
    @IBAction func onDismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

