//
//  Channel.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

class Channel: NSObject {

    var dictionary: NSMutableDictionary?
    let owner: User?
    let channel_id: String?
    var title: String? {
        didSet {
            self.dictionary?.setValue(title!, forKey: "title")
        }
    }
    var thumbnail_url: String? {
        didSet {
            self.dictionary?.setValue(thumbnail_url!, forKey: "thumbnail_url")
        }
    }
    var items: [ChannelItem]? {
        didSet {
            self.dictionary?.setValue(items, forKey: "items")
        }
    }
    var filters: Filters? {
        didSet {
            let max_duration = filters!.max_duration
            let dict = ["max_duration": max_duration!]
            self.dictionary?.setValue(dict, forKey: "filters")
        }
    }
    var topics: [String]? {
        didSet {
            self.dictionary?.setValue(topics, forKey: "topics")
        }
    }
    var curated: CuratedInfo? {
        didSet {
            dictionary?.setValue(curated, forKey: "curated")
        }
    }
    
    init(dictionary: NSDictionary) {
        let dict = dictionary
        self.dictionary = dict.mutableCopy() as? NSMutableDictionary
        
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
    
    private func filterToDictionary() {
        
    }
    
    class func channelsWithArray(array: [NSDictionary]) -> [Channel] {
        var channels = [Channel]()
        
        for dictionary in array {
            channels.append(Channel(dictionary: dictionary))
        }
        
        return channels
    }
}

