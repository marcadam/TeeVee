//
//  Channel.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class Channel: NSObject {
    let dictionary: NSDictionary
    let channel_id: String?
    let items: [ChannelItem]
    let thumbnail_url: String?
    let name: String?
    let filter: Filter?

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var channel_id: String? = ""
        var items = [ChannelItem]()
        var thumbnail_url: String? = "https://i.ytimg.com/vi/tntOCGkgt98/maxresdefault.jpg"
        var name: String? = ""
        var filter: Filter?
        
        name = dictionary["name"] as? String
        filter = dictionary["filter"] as? Filter
        thumbnail_url = dictionary["thumbnail_url"] as? String
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        self.channel_id = dictionary["id"] as? String
        self.items = items
        self.filter = filter
        self.name = name
        self.thumbnail_url = thumbnail_url
    }
    
    
    class func channelsWithArray(array: [NSDictionary]) -> [Channel] {
        var channels = [Channel]()
        
        for dictionary in array {
            channels.append(Channel(dictionary: dictionary))
        }
        
        return channels
    }
}

