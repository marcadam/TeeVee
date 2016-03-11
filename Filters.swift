//
//  Filters.swift
//  SmartStream
//
//  Created by Jerry on 3/9/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class Filters: NSObject {
    let dictionary: NSDictionary
    var sources: [String]?
    var max_duration: Int?
    let likes: [ChannelItem]?
    let dislikes: [ChannelItem]?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        sources = dictionary["sources"] as? [String]
        max_duration = dictionary["max_duration"] as? Int
        likes = dictionary["likes"] as? [ChannelItem]
        dislikes = dictionary["dislikes"] as? [ChannelItem]
    }
}