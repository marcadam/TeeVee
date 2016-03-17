//
//  Mock.swift
//  SmartStream
//
//  Created by Jerry on 3/9/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

struct Mock {
    enum NewUser {
        case Tom
    
        var user: User {
            switch self {
            case .Tom: return User(dictionary: ["name": "Tom Cruise", "username": "tcruisin"])
            }
        }
    }
    
//    enum NewChannelItem {
//        case Cats
//        var items: [NSDictionary] {
//            
//        }
//        
//        init(topics: [String]) {
//            var itemArray = [NSDictionary]()
//            for _ in topics {
//                let url: String = "https://www.youtube.com/watch?v=tntOCGkgt98"
//                let native_id: String = "tntOCGkgt98"
//                let extractor: String = "youtube"
//                let channelItem = ["url": url, "native_id": native_id, "extractor": extractor] as NSDictionary
//                itemArray.append(channelItem)
//            }
//            items = itemArray
//        }
//    }
}
