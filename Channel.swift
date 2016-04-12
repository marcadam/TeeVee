//
//  Channel.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

struct ItemInProgress {
    var item: ChannelItem?
    var seconds: Float
}

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
    let isSuggested: Bool
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var items = [ChannelItem]()
        var curated: CuratedInfo? = nil
        var setFilters: Filters? = nil
        var isSuggested = false
        
        channel_id = dictionary["_id"] as? String
        title = dictionary["title"] as? String
        thumbnail_url = dictionary["thumbnail_url"] as? String
        
        if let itemsArray = dictionary["items"] as? [NSDictionary] {
            items = ChannelItem.items(array: itemsArray)
        }
        
        if let curatedInfo = dictionary["curated"] as? NSDictionary {
            curated = CuratedInfo(dictionary: curatedInfo)
        }
        
        if let filters = dictionary["filters"] as? NSDictionary {
            setFilters = Filters(dictionary: filters)
        }
        
        if let isSuggestedInfo = dictionary["suggested"] {
            isSuggested = isSuggestedInfo.boolValue
        }
        
        self.items = items
        self.curated = curated
        self.filters = setFilters
        self.isSuggested = isSuggested
        
        topics = dictionary["topics"] as? [String]
        owner = dictionary["owner"] as? User
    }
    
    private func filterToDictionary() {
        
    }
    
    func getItemInProgress() -> (ItemInProgress) {
        var item = ItemInProgress(item: nil, seconds: Float.NaN)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let keyExists = userDefaults.objectForKey("\(self.channel_id!)_inprogress_seconds") {
            item.seconds = userDefaults.floatForKey("\(self.channel_id!)_inprogress_seconds")
        }
        
        let data = userDefaults.objectForKey("\(self.channel_id!)_inprogress") as? NSData
        if data != nil {
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                debugPrint("[DEBUG] itemInProgress NOT nil")
                item.item =  ChannelItem(dictionary: dictionary)
            } catch {
                debugPrint("[DEBUG] itemInProgress == nil")
            }
        }
        
        return item
    }
    
    func setItemInProgress(itemInProgress: ItemInProgress) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(itemInProgress.seconds, forKey: "\(self.channel_id!)_inprogress_seconds")
        userDefaults.synchronize()
        
        if itemInProgress.item == nil {
            userDefaults.setObject(nil, forKey: "\(self.channel_id!)_inprogress")
        } else {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(itemInProgress.item!.dictionary, options: []) as NSData
                userDefaults.setObject(data, forKey: "\(self.channel_id!)_inprogress")
            } catch {
                userDefaults.setObject(nil, forKey: "\(self.channel_id!)_inprogress")
            }
        }
        userDefaults.synchronize()
    }
    
    class func channelsWithArray(array: [NSDictionary]) -> [Channel] {
        var channels = [Channel]()
        
        for dictionary in array {
            channels.append(Channel(dictionary: dictionary))
        }
        
        return channels
    }

}

