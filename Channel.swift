//
//  Channel.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class Channel: NSObject {

    let dictionary: NSDictionary?
    let channel_id: String?
    let name: String?
    let thumbnail_url: String?
    let items: [ChannelItem]?
    let filters: Filter?
    let topics: [String]?

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        channel_id = dictionary["channel_id"] as? String
        name = dictionary["name"] as? String
        thumbnail_url = dictionary["thumbnail_url"] as? String
        
        let itemsArray = dictionary["items"] as? [NSDictionary]
        items = ChannelItem.items(array: itemsArray!)
        
        filters = dictionary["filters"] as? Filter
        topics = dictionary["topics"] as? [String]
    }
    
    
    class func channelsWithArray(array: [NSDictionary]) -> [Channel] {
        var channels = [Channel]()
        
        for dictionary in array {
            channels.append(Channel(dictionary: dictionary))
        }
        
        return channels
    }
}

