//
//  Data.swift
//  SmartStream
//
//  Created by Jerry on 3/8/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class DataLayer: NSObject {
    class func createChannel(keywordsArray:[String], withFilter filter: Filter, completion: (channel: Channel)->()) {
        let channelID = generateID()
        let itemDictionary = generateItemDictionary(keywordsArray)
        let filter = filter
        let channelDictionary = ["channel_id": channelID, "items": itemDictionary, "filter":filter]
        let channelDict = ["channel": channelDictionary] as NSDictionary
        let channel = Channel(dictionary: channelDict)
        completion(channel: channel)
    }
    
    static func generateID() -> String {
        let date = NSDate()
        let uniqueID = String(UInt64(floor(date.timeIntervalSince1970)))
        return uniqueID
    }
    
    static func generateItemDictionary(keywords:[String]) -> [NSDictionary] {
        var itemArray = [NSDictionary]()
        for _ in keywords {
            let url: String = "https://www.youtube.com/watch?v=tntOCGkgt98"
            let native_id: String = "tntOCGkgt98"
            let extractor: String = "youtube"
            itemArray.append(["url": url, "native_id": native_id, "extractor": extractor] as NSDictionary)
        }
        return itemArray
    }
    
}
