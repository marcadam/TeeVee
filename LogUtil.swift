//
//  LogUtil.swift
//  TeeVee
//
//  Created by Hieu Nguyen on 4/14/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import Foundation
import Crashlytics

func DebugLog(message: String,
              file: StaticString = #file,
              function: StaticString = #function,
              line: Int = #line)
{
    let output: String
    if let filename = NSURL(string:file.stringValue)?.lastPathComponent?.componentsSeparatedByString(".").first
    {
        output = "\(filename).\(function) line \(line) $ \(message)"
    }
    else
    {
        output = "\(file).\(function) line \(line) $ \(message)"
    }
    
    #if DEBUG
        CLSNSLogv(output, getVaList([]))
    #else
        CLSLogv(output, getVaList([]))
    #endif
}