//
//  TweetUser.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/15/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class TweetUser: NSObject {
    let dictionary: NSDictionary
    let name: String?
    let screenname: String?
    let profileImageLowResUrl: String?
    let profileImageUrl: String?
    let profileBannerImage: String?
    let profileBackgroundImageUrl: String?
    let tagline: String?
    let tweetsCount: Int?
    let likesCount: Int?
    let followingCount: Int?
    let followersCount: Int?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        var name = ""
        var screenname = ""
        var profileImageLowResUrl = ""
        var profileImageUrl = ""
        var profileBackgroundImageUrl = ""
        var profileBannerImage = ""
        var tagline = ""
        var tweetsCount: Int? = 0
        var likesCount: Int? = 0
        var followingCount: Int? = 0
        var followersCount: Int? = 0
        
        if let nameStr = dictionary["name"] as? String {
            name = nameStr
        }
        if let screennameStr = dictionary["screen_name"] as? String {
            screenname = screennameStr
        }
        
        if let profileImageUrlStr = dictionary["profile_image_url"] as? String {
            profileImageLowResUrl = profileImageUrlStr
            profileImageUrl = profileImageUrlStr.stringByReplacingOccurrencesOfString("_normal", withString: "")
        }
        
        if let profileBackgroundImageUrlStr = dictionary["profile_background_image_url"] as? String {
            profileBackgroundImageUrl = profileBackgroundImageUrlStr
        }
        
        if let profileBannerImageStr = dictionary["profile_banner_url"] as? String {
            profileBannerImage = profileBannerImageStr
        }
        
        
        if let taglineStr = dictionary["description"] as? String {
            tagline = taglineStr
        }
        
        if let tweetsCountStr = dictionary["statuses_count"] as? Int {
            tweetsCount = tweetsCountStr
        }
        
        if let likesCountStr = dictionary["favourites_count"] as? Int {
            likesCount = likesCountStr
        }
        
        if let followingCountStr = dictionary["friends_count"] as? Int {
            followingCount = followingCountStr
        }
        
        if let followersCountStr = dictionary["followers_count"] as? Int {
            followersCount = followersCountStr
        }
        
        self.name = name
        self.screenname = screenname
        self.profileImageLowResUrl = profileImageLowResUrl
        self.profileImageUrl = profileImageUrl
        self.profileBannerImage = profileBannerImage
        self.profileBackgroundImageUrl = profileBackgroundImageUrl
        self.tagline = tagline
        self.tweetsCount = tweetsCount
        self.likesCount = likesCount
        self.followingCount = followingCount
        self.followersCount = followersCount
    }
    
}
