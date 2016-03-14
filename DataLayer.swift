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
        let filtersDict = filtersToDictionary(filters)
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
    
    class func updateChannel(withDictionary dictionary: NSDictionary, completion: (error: NSError?, channel: Channel?) -> ()) {
        
        let channel_id = dictionary["channel_id"] as! String
        let topics = dictionary["topics"] as! [String]
        let filters = dictionary["filters"] as! Filters
        let filtersDict = filtersToDictionary(filters)
        let title = dictionary["title"] as! String
        
        let channelDictionary =
        ["channel": [
            "title": title,
            "filters": filtersDict,
            "topics": topics
            ]
        ] as NSDictionary
        
        ChannelClient.sharedInstance.updateChannel(channel_id, channelDict: channelDictionary) { (channel, error) -> () in
            if error != nil {
                completion(error: error!, channel: nil)
            } else {
                completion(error: nil, channel: channel!)
            }
        }
    }
    
    class func deleteChannel(withChannelId channel_id: String, completion: (error: NSError?, channelId: String?) -> ()) {
        ChannelClient.sharedInstance.deleteChannel(channel_id) { (channelId, error) -> () in
            if error != nil {
                completion(error: error!, channelId: nil)
            } else {
                completion(error: nil, channelId: channelId)
            }
        }
    }
    
    static func filtersToDictionary(filters: Filters) -> NSDictionary {
        let dictionary = ["max_duration": filters.max_duration!] as NSDictionary
        return dictionary
    }
    
//    static func generateID() -> String {
//        let date = NSDate()
//        let uniqueID = String(UInt64(floor(date.timeIntervalSince1970)))
//        return uniqueID
//    }

}
