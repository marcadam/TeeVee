//
//  ChannelItem.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class ChannelItem: NSObject, Comparable {
    let dictionary: NSDictionary
    let url: String?
    let id: String?
    let extractor: String?
    var timestamp: NSTimeInterval?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        url = dictionary["url"] as? String
        id = dictionary["id"] as? String
        extractor = dictionary["extractor"] as? String
        timestamp = NSDate().timeIntervalSince1970
    }
    
    class func items(array array: [NSDictionary]) -> [ChannelItem] {
        var items = [ChannelItem]()
        for dictionary in array {
            let item = ChannelItem(dictionary: dictionary)
            items.append(item)
        }
        return items
    }
}

// ==========================================================
// Note: for now the items are ordered based on their 
//       timestamps but this can easily be modified to look at 
//       the priority field first (when there is one), so they
//       would be ordered based on priorities. And only look
//       at the timestamp for tie-breaker.
// ==========================================================
func < (lhs: ChannelItem, rhs: ChannelItem) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

func == (lhs: ChannelItem, rhs: ChannelItem) -> Bool {
    return lhs.timestamp == rhs.timestamp
}
