//
//  ProgressbarView.swift
//  SmartStream
//
//  Created by Jerry on 3/17/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class ProgressbarView: UIView {

    var progressView:UIView!
    var progressbarColor: UIColor = UIColor.redColor()
    private var barHeight: CGFloat!
    private var barWidth: CGFloat!
    
    override func drawRect(rect: CGRect) {
        
        // Must be set when the rect is drawn
        barHeight = rect.height
        barWidth = rect.width
        progressView = UIView(frame: CGRectMake(0, 0, 1, rect.height))
        //progressView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        progressView.backgroundColor = progressbarColor
        addSubview(progressView)
        updateProgressBar(0, totalDuration: 1)
    }
    
    func  updateProgressBar(progress: Double, totalDuration: Double) {
        let fraction = progress/totalDuration

        let widthScale = CGFloat(fraction) * barWidth
        //progressView.frame = CGRectMake(0, 0, barWidth * widthPercent, barHeight)
        progressView.layer.removeAllAnimations()
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.progressView.transform = CGAffineTransformMakeScale(widthScale * 2, 1)
            //debugPrint("PROGRESS: \(self.progressView.frame.width)")
            //debugPrint("PROGRESS BAR: \(self.frame.width)")
        })
        
    }

}
