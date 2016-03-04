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
    let streamId: String?
    let items: [StreamItem]
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var streamId: String? = ""
        var items = [StreamItem]()
        
        if let stream = dictionary["stream"] as? NSDictionary {
            streamId = stream["stream_id"] as? String
            if let itemsArray = stream["items"] as? [NSDictionary] {
                items = StreamItem.items(array: itemsArray)
            }
        }
        
        self.streamId = streamId
        self.items = items
    }
}