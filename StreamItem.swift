//
//  StreamItem.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class StreamItem: NSObject {
    let dictionary: NSDictionary
    let contentType: String?
    let source: String?
    let url: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        contentType = dictionary["content_type"] as? String
        source = dictionary["source"] as? String
        url = dictionary["url"] as? String
    }
    
    class func items(array array: [NSDictionary]) -> [StreamItem] {
        var items = [StreamItem]()
        for dictionary in array {
            let item = StreamItem(dictionary: dictionary)
            items.append(item)
        }
        return items
    }
}