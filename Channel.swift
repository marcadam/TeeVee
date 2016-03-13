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
    let owner: User?
    let channel_id: String?
    let title: String?
    let thumbnail_url: String?
    let items: [ChannelItem]?
    let filters: Filters?
    let topics: [String]?
    let curated: CuratedInfo?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var items = [ChannelItem]()
        var curated: CuratedInfo? = nil
        
        channel_id = dictionary["_id"] as? String
        title = dictionary["title"] as? String
        thumbnail_url = dictionary["thumbnail_url"] as? String
        
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        if let curatedInfo = dictionary["curated"] as? NSDictionary {
            curated = CuratedInfo(dictionary: curatedInfo)
        }
        
        self.items = items
        self.curated = curated
        filters = dictionary["filters"] as? Filters
        topics = dictionary["topics"] as? [String]
        owner = dictionary["owner"] as? User
    }
    
    
    class func channelsWithArray(array: [NSDictionary]) -> [Channel] {
        var channels = [Channel]()
        
        for dictionary in array {
            channels.append(Channel(dictionary: dictionary))
        }
        
        return channels
    }
}

