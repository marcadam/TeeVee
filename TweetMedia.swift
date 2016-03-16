//
//  Media.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/15/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class TweetMedia: NSObject {
    let dictionary: NSDictionary
    
    let mediaUrl: String?
    let type = "photo"
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var mediaUrl: String? = nil
        if let mediaUrlStr = dictionary["media_url"] as? String {
            mediaUrl = mediaUrlStr
        }
        
        self.mediaUrl = mediaUrl
        //print(self.mediaUrl!)
    }
}

