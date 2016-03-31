//
//  StopTimer.swift
//  TeeVee
//
//  Created by Hieu Nguyen on 3/31/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import Foundation

class StopWatch {
    
    let startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
