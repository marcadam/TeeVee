//
//  CuratedInfo.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/12/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class CuratedInfo: NSObject {
    let dictionary: NSDictionary
    let group: Int?
    let type: String?
    let cover_url: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        self.group = dictionary["group"] as? Int
        self.type = dictionary["type"] as? String
        self.cover_url = dictionary["cover_url"] as? String
    }
}
