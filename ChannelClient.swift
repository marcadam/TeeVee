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
    
    
    func createChannel(channelDict: NSDictionary!, completion: (channel: Channel?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels")!
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(channelDict, options: [])
            let request = NSMutableURLRequest(URL: endpoint)
            request.HTTPMethod = "POST"
            
            let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data, completionHandler: { (responseData: NSData?, response: NSURLResponse?, apiError: NSError?) -> Void in
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: []) as? NSDictionary
                    //print(json!)
                    let channel = Channel(dictionary: json!)
                    completion(channel: channel, error: nil)
                } catch {
                    print(error)
                    completion(channel: nil, error: apiError)
                }
            })
            
            task.resume()
        } catch {
            completion(channel: nil, error: NSError(domain: "serialization failed", code: 0, userInfo: nil))
        }
    }
    
    
    func updateChannel(channelId: String!, channelDict: NSDictionary!, completion: (channel: Channel?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels/" + channelId)!
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(channelDict, options: [])
            let request = NSMutableURLRequest(URL: endpoint)
            request.HTTPMethod = "PUT"
            
            let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data, completionHandler: { (responseData: NSData?, response: NSURLResponse?, apiError: NSError?) -> Void in
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: []) as? NSDictionary
                    //print(json!)
                    let channel = Channel(dictionary: json!)
                    completion(channel: channel, error: nil)
                } catch {
                    print(error)
                    completion(channel: nil, error: apiError)
                }
            })
            
            task.resume()
        } catch {
            completion(channel: nil, error: NSError(domain: "serialization failed", code: 0, userInfo: nil))
        }
    }
    
    
    func deleteChannel(channelId: String!, completion: (channelId: String!, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels/" + channelId)!
        
        let request = NSMutableURLRequest(URL: endpoint)
        request.HTTPMethod = "DELETE"
        
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: nil, completionHandler: { (responseData: NSData?, response: NSURLResponse?, apiError: NSError?) -> Void in
            
            completion(channelId: channelId, error: apiError)
        })
        
        task.resume()
    }
    
    
    func getChannel(channelId: String!, completion: (channel: Channel?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels/" + channelId)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
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
    
    
    func streamChannel(channelId: String!, completion: (channel: Channel?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "stream/" + channelId)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
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
    
    
    func getMyChannels(completion: (channels: [Channel]?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "channels")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [NSDictionary]
                //print(json!)
                let channels = Channel.channelsWithArray(json!)
                completion(channels: channels, error: nil)
            } catch {
                print(error)
                completion(channels: nil, error: apiError)
            }
        }
        
        task.resume()
    }
    
    func getBrowseChannels(completion: (channels: [Channel]?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "browse")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [NSDictionary]
                //print(json!)
                let channels = Channel.channelsWithArray(json!)
                completion(channels: channels, error: nil)
            } catch {
                print(error)
                completion(channels: nil, error: apiError)
            }
        }
        
        task.resume()
    }
    
    func getAvailableFilter(completion: (filter: Filter?, error: NSError?) -> ()) {
        let endpoint = NSURL(string: baseURL + "filter")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(endpoint) {(data: NSData?, response: NSURLResponse?, apiError: NSError?) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                //print(json!)
                let filter = Filter(dictionary: json!)
                completion(filter: filter, error: nil)
            } catch {
                print(error)
                completion(filter: nil, error: apiError)
            }
        }
        
        task.resume()
    }
}
