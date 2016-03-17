//
//  User.swift
//  SmartStream
//
//  Created by Jerry on 3/9/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class User: NSObject {
    let dictionary: NSDictionary
    let name: String?
    let username: String?
    let imageUrl: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        username = dictionary["username"] as? String
        imageUrl = dictionary["imageurl"] as? String
    }
}
