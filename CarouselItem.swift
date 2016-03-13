//
//  CarouselItem.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/12/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

class CarouselItem: NSObject {
    let dictionary: NSDictionary
    let cover_url: String?
    let title: String?
    let subtitle: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        self.cover_url = dictionary["cover_url"] as? String
        self.title = dictionary["title"] as? String
        self.subtitle = dictionary["subtitle"] as? String
    }
    
    class func carouselItemsWithArray(array: [NSDictionary]) -> [CarouselItem] {
        var carouselItems = [CarouselItem]()
        
        for dictionary in array {
            carouselItems.append(CarouselItem(dictionary: dictionary))
        }
        
        return carouselItems
    }
}
