//
//  Filters.swift
//  SmartStream
//
//  Created by Jerry on 3/9/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class Filters: NSObject {
    var dictionary: NSMutableDictionary
    var sources: [String]?
    var max_duration: Int?
    var likes: [ChannelItem]?
    var dislikes: [ChannelItem]?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary as! NSMutableDictionary
        sources = dictionary["sources"] as? [String]
        max_duration = dictionary["max_duration"] as? Int
        likes = dictionary["likes"] as? [ChannelItem]
        dislikes = dictionary["dislikes"] as? [ChannelItem]
    }
    
    func updateDictionary(ofKey key: String, withValue value: AnyObject) {
        
        dictionary.setValue(value, forKey: key)
        
//        switch key {
//        case "sources": dictionary["sources"] = value as! [String]
//        case "max_duration": dictionary["max_duration"] = value as! Int
//        case "likes": dictionary["likes"] = value as! [ChannelItem]
//        case "dislikes": dictionary["dislikes"] = value as! [ChannelItem]
//        default: break
//        }
    }
}
