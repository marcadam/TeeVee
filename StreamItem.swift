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
    let url: String?
    let id: String?
    let extractor: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        url = dictionary["url"] as? String
        id = dictionary["id"] as? String
        extractor = dictionary["extractor"] as? String
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