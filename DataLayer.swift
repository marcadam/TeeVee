//
//  Data.swift
//  SmartStream
//
//  Created by Jerry on 3/8/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class DataLayer: NSObject {
    class func createChannel(withDictionary dictionary: NSDictionary, completion: (channel: Channel)->()) {
//        let channelID = generateID()
        let topics = dictionary["topics"] as! [String]
        let filters = dictionary["filters"] as! Filters
        let filtersDict = filters.dictionary 
        let title = dictionary["title"] as! String
        
//        let itemDictionary = Mock.NewChannelItem.init(topics: topics).items
//        let owner = Mock.NewUser().user
        
        let channelDictionary = ["title": title, "filters": filtersDict, "topics": topics] as NSDictionary
        ChannelClient.sharedInstance.createChannel(channelDictionary) { (channel, error) -> () in
            if error != nil {
               print(error)
            } else {
               completion(channel: channel!)
            }
        }
    }
    
//    static func generateID() -> String {
//        let date = NSDate()
//        let uniqueID = String(UInt64(floor(date.timeIntervalSince1970)))
//        return uniqueID
//    }

}
