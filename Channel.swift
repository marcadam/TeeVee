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
    let channelId: String?
    let items: [ChannelItem]
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var items = [ChannelItem]()
        
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        self.channelId = dictionary["id"] as? String
        self.items = items
    }
}