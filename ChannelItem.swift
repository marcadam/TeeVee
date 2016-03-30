//
//  ChannelItem.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class ChannelItem: NSObject, NSCopying, Comparable {
    let dictionary: NSDictionary
    let url: String?
    let native_id: String?
    let extractor: String?
    let topic: String?
    let timestamp: NSTimeInterval?
    let tweet: Tweet?
    var priority: Int = 100
    
    required init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        url = dictionary["url"] as? String
        native_id = dictionary["native_id"] as? String
        extractor = dictionary["extractor"] as? String
        topic = dictionary["topic"] as? String
        
        var tweet: Tweet? = nil
        if let tweetDict = dictionary["tweet"] as? NSDictionary {
            tweet = Tweet(dictionary: tweetDict)
        }
        
        self.tweet = tweet
        timestamp = NSDate().timeIntervalSince1970
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(dictionary: dictionary)
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
    if lhs.priority < rhs.priority {
        return true
    } else if lhs.priority == rhs.priority && lhs.timestamp < rhs.timestamp {
        return true
    }
    
    return false
}

func == (lhs: ChannelItem, rhs: ChannelItem) -> Bool {
    return lhs.priority == rhs.priority && lhs.timestamp == rhs.timestamp
}
