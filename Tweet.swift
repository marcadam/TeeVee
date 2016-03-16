//
//  Tweet.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/15/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

//
//  Tweet.swift
//  HugoTwitter
//
//  Created by Hieu Nguyen on 2/17/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    let dictionary: NSDictionary
    let id: String?
    let user: TweetUser?
    let text: String?
    let createdAtString: String?
    let createdAt: NSDate?
    let retweetName: String?
    let replyName: String?
    var favorited: Bool
    var retweeted: Bool
    var retweetCount: Int
    var favCount: Int
    let retweetOriginalId: String?
    let media: TweetMedia?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var id: String? = nil
        var user: TweetUser? = nil
        var text = ""
        var createdAtString = ""
        var createdAt: NSDate? = nil
        var retweetName: String? = nil
        var replyName: String? = nil
        var favorited = false
        var retweeted = false
        var retweetCount = 0
        var favCount = 0
        var retweetOriginalId: String? = nil
        var media: TweetMedia?
        
        if let idStr = dictionary["id_str"] as? String {
            id = idStr
            retweetOriginalId = idStr
        }
        
        if let userDict = dictionary["user"] as? NSDictionary {
            user = TweetUser(dictionary: userDict)
        }
        if let textStr = dictionary["text"] as? String {
            text = textStr
        }
        if let createdAtStr = dictionary["created_at"] as? String {
            createdAtString = createdAtStr
            createdAt = DateManager.defaultFormatter.dateFromString(createdAtString)
        }
        
        if let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary {
            // not an original
            retweetOriginalId = retweetedStatus["id_str"] as? String
            
            if let retweetUserDict = retweetedStatus["user"] as? NSDictionary {
                let retweetUser = TweetUser(dictionary: retweetUserDict)
                retweetName = user!.name!
                user = retweetUser
            }
            if let textStr = retweetedStatus["text"] as? String{
                text = textStr
            }
        }
        
        if let repliedTo = dictionary["in_reply_to_screen_name"] as? String {
            replyName = repliedTo
        }
        
        if let favoritedData = dictionary["favorited"] as? Bool {
            favorited = favoritedData
        }
        if let retweetedData = dictionary["retweeted"] as? Bool {
            retweeted = retweetedData
        }
        
        if let retweetCountData = dictionary["retweet_count"] as? Int {
            retweetCount = retweetCountData
        }
        if let favCountData = dictionary["favorite_count"] as? Int {
            favCount = favCountData
        }
        
        if let entities = dictionary["entities"] as? NSDictionary {
            if let mediaArray = entities["media"] as? NSArray {
                if mediaArray.count > 0 {
                    media = TweetMedia(dictionary: mediaArray[0] as! NSDictionary)
                }
            }
        }
        
        self.id = id
        self.user = user
        self.text = text
        self.createdAtString = createdAtString
        self.createdAt = createdAt
        self.retweetName = retweetName
        self.replyName = replyName
        self.favorited = favorited
        self.retweeted = retweeted
        self.retweetCount = retweetCount
        self.favCount = favCount
        self.retweetOriginalId = retweetOriginalId
        self.media = media
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
