//
//  StreamClient.swift
//  SmartStream
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit

let streamBaseUrl = "http://smartu.herokuapp.com/api/"
class StreamClient {
    var baseURL: String!
    
    static let sharedInstance = StreamClient(baseURL: streamBaseUrl)
    
    private init(baseURL: String!) {
        self.baseURL = baseURL
    }
    
    func getStream(completion: (stream: Stream?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "stream.json")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint!) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                //print(json!)
                let stream = Stream(dictionary: json!)
                completion(stream: stream, error: nil)
            } catch {
                print(error)
                completion(stream: nil, error: apiError)
            }
        }
        
        task.resume()
    }
}
