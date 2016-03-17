//
//  GradientView.swift
//  SmartStream
//
//  Created by Jerry on 3/17/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // Default Colors
    var colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor()]
    
    override func drawRect(rect: CGRect) {
        
        // Must be set when the rect is drawn
        setGradient(colors[0], color2: colors[1])
    }
    
    func setGradient(color1: UIColor, color2: UIColor) {
        
        let context = UIGraphicsGetCurrentContext()
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [color1.CGColor, color2.CGColor], [0, 1])!
        
        // Draw Path
        let path = UIBezierPath(rect: CGRectMake(0, 0, frame.width, frame.height))
        CGContextSaveGState(context)
        path.addClip()
        CGContextDrawLinearGradient(context, gradient, CGPointMake(frame.width / 2, 0), CGPointMake(frame.width / 2, frame.height), CGGradientDrawingOptions())
        CGContextRestoreGState(context)
    }
    
    override func layoutSubviews() {
        
        // Ensure view has a transparent background color (not required)
        backgroundColor = UIColor.clearColor()
    }
    
}
