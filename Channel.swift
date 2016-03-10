//
//  Channel.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class Channel: NSObject {
    let thumbnail_url: String?
    let name: String?
    let dictionary: NSDictionary
    let channel_id: String?
    let items: [ChannelItem]
    let filters: Filter?

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var thumbnail_url: String? = "https://i.ytimg.com/vi/tntOCGkgt98/maxresdefault.jpg"
        var name: String? = ""
        var channel_id: String? = ""
        var items = [ChannelItem]()
        var filters: Filter?
        
        name = dictionary["name"] as? String
        filters = dictionary["filters"] as? Filter
        thumbnail_url = dictionary["thumbnail_url"] as? String
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        self.channel_id = dictionary["id"] as? String
        self.items = items
        self.filters = filters
        self.name = name
        self.thumbnail_url = thumbnail_url
    }
}

