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
    let type: String?
    let carousel_items: [CarouselItem]?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        self.type = dictionary["type"] as? String
        
        var carousel_items = [CarouselItem]()
        if let carouselItems = dictionary["carousel_items"] as? [NSDictionary] {
            carousel_items = CarouselItem.carouselItemsWithArray(carouselItems)
        }
        self.carousel_items = carousel_items
    }
}
