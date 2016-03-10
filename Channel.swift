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
        
        if let channel = dictionary["channel"] as? NSDictionary {
            name = channel["name"] as? String
            channel_id = channel["channel_id"] as? String
            filters = channel["filters"] as? Filter
            thumbnail_url = channel["thumbnail_url"] as? String
            if let itemsArray = channel["items"] as? [NSDictionary] {
                items = ChannelItem.items(array: itemsArray)
            }
        }
        
        self.channel_id = channel_id
        self.items = items
        self.filters = filters
        self.name = name
        self.thumbnail_url = thumbnail_url
    }
}