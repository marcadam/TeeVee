//
//  ChannelClient.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

let channelBaseUrl = "http://smartu.herokuapp.com/api/"
class ChannelClient {
    var baseURL: String!
    
    static let sharedInstance = ChannelClient(baseURL: channelBaseUrl)
    
    private init(baseURL: String!) {
        self.baseURL = baseURL
    }
    
    func getChannel(completion: (channel: Channel?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels/1")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint!) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                //print(json!)
                let channel = Channel(dictionary: json!)
                completion(channel: channel, error: nil)
            } catch {
                print(error)
                completion(channel: nil, error: apiError)
            }
        }
        
        task.resume()
    }
}
