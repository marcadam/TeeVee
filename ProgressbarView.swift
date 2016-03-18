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
    var mainColor: UIColor = UIColor.whiteColor()
    private var barHeight: CGFloat!
    private var barWidth: CGFloat!
    
    override func drawRect(rect: CGRect) {
        
        // Must be set when the rect is drawn
        backgroundColor = mainColor
        barHeight = rect.height
        barWidth = rect.width
        progressView = UIView(frame: CGRectMake(0, 0, 1, rect.height))
        progressView.backgroundColor = progressbarColor
        addSubview(progressView)
        updateProgressBar(0, totalDuration: 1)
    }
    
    func  updateProgressBar(progress: Double, totalDuration: Double) {
        let fraction = progress/totalDuration

        let widthScale = CGFloat(fraction) * barWidth
        //progressView.frame = CGRectMake(0, 0, barWidth * widthPercent, barHeight)
        progressView.transform = CGAffineTransformMakeScale(widthScale * 2, 1)
        
    }

}
