//
//  HighlightedStateView.swift
//  SmartStream
//
//  Created by Jerry on 3/22/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class HighlightedStateView: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.layer.opacity = 0.5
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.layer.opacity = 1
        })
    }
    
    override func didMoveToWindow() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.layer.opacity = 1
        })
    }
    
}
