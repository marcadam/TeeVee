//
//  Data.swift
//  SmartStream
//
//  Created by Jerry on 3/8/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class DataLayer: NSObject {
    class func createChannel(withDictionary dictionary: NSDictionary, completion: (error: NSError?, channel: Channel?) -> ()) {
//        let channelID = generateID()
        let topics = dictionary["topics"] as! [String]
        let filters = dictionary["filters"] as! Filters
        let filtersDict = filters.dictionary 
        let title = dictionary["title"] as! String
        
//        let itemDictionary = Mock.NewChannelItem.init(topics: topics).items
//        let owner = Mock.NewUser().user
        
        let channelDictionary =
            ["channel": [
                "title": title,
                "filters": filtersDict,
                "topics": topics
                ]
            ] as NSDictionary
        
        ChannelClient.sharedInstance.createChannel(channelDictionary) { (channel, error) -> () in
            if error != nil {
               print(error)
                completion(error: error!, channel: nil)
            } else {
                completion(error: nil, channel: channel!)
            }
        }
    }
    
    class func updateChannel(withChannel channel: Channel, completion: (error: NSError?, channel: Channel?) -> ()) {
        
        let topics = channel.dictionary!["topics"] as! [String]
        let filters = channel.dictionary!["filters"] as! NSDictionary
        let title = channel.dictionary!["title"] as! String
        
        let channelDictionary =
        ["channel": [
            "title": title,
            "filters": filters,
            "topics": topics
            ]
        ] as NSDictionary
        
        ChannelClient.sharedInstance.updateChannel(channel.channel_id, channelDict: channelDictionary) { (channel, error) -> () in
            if error != nil {
                completion(error: error!, channel: nil)
            } else {
                completion(error: nil, channel: channel!)
            }
        }
    }
    
    class func deleteChannel(withChannel channel: Channel, completion: (error: NSError?, channelId: String?) -> ()) {
        ChannelClient.sharedInstance.deleteChannel(channel.channel_id) { (channelId, error) -> () in
            if error != nil {
                completion(error: error!, channelId: nil)
            } else {
                completion(error: nil, channelId: channelId)
            }
        }
    }
    
//    static func generateID() -> String {
//        let date = NSDate()
//        let uniqueID = String(UInt64(floor(date.timeIntervalSince1970)))
//        return uniqueID
//    }

}
