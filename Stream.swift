//
//  Stream.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class Stream: NSObject {
    let dictionary: NSDictionary
    let channelId: String?
    let items: [StreamItem]
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var channelId: String? = ""
        var items = [StreamItem]()
        
        if let stream = dictionary["stream"] as? NSDictionary {
            channelId = stream["channel_id"] as? String
            if let itemsArray = stream["items"] as? [NSDictionary] {
                items = StreamItem.items(array: itemsArray)
            }
        }
        
        self.channelId = channelId
        self.items = items
    }
}