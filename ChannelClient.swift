//
//  ChannelClient.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 3/3/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import AFNetworking

let channelBaseUrl = "http://smartu.herokuapp.com/"
class ChannelClient {
    var baseURL: String!
    
    static let sharedInstance = ChannelClient(baseURL: channelBaseUrl)
    var manager: AFHTTPSessionManager!
    private init(baseURL: String!) {
        self.baseURL = baseURL
        self.manager = AFHTTPSessionManager(baseURL: NSURL(string: channelBaseUrl))
        self.manager.requestSerializer = AFJSONRequestSerializer()
        self.manager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        //self.manager.responseSerializer.acceptableContentTypes = nil
        
//        let contentTypes = NSSet(array: ["text/plain", "text/html"])
//        self.manager.responseSerializer.acceptableContentTypes = (contentTypes as! Set<String>)
        
        var acceptableContentTypes = Set<String>()
        acceptableContentTypes.insert("text/plain")
        acceptableContentTypes.insert("text/html")
        self.manager.responseSerializer.acceptableContentTypes = acceptableContentTypes
        
    }
    
    func authenticateFacebook(accessToken: String, completion: (user: User?, error: NSError?) -> ()) {
        let params = ["access_token": accessToken]
        manager.POST("auth/facebook/token", parameters: params, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            debugPrint(response)
            if let json = response as? NSDictionary {
                let user = User(dictionary: json)
                completion(user: user, error: nil)
            } else {
                completion(user: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
        }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
            let response = dataTask?.response as? NSHTTPURLResponse
            if response != nil {
                debugPrint("authenticateFacebook() status code = \(response!.statusCode)")
            }
            completion(user: nil, error: error)
        }
    }
    
    func createChannel(channelDict: NSDictionary!, completion: (channel: Channel?, error: NSError?) -> ()) {
        
        manager.POST("api/channels", parameters: channelDict, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let channel = Channel(dictionary: json)
                completion(channel: channel, error: nil)
            } else {
                completion(channel: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("createChannel() status code = \(response!.statusCode)")
                }
                completion(channel: nil, error: error)
        }
        
    }
    
    
    func updateChannel(channelId: String!, channelDict: NSDictionary?, completion: (channel: Channel?, error: NSError?) -> ()) {
        
        manager.PUT(String("api/channels/" + channelId), parameters: channelDict, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let channel = Channel(dictionary: json)
                completion(channel: channel, error: nil)
            } else {
                completion(channel: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("updateChannel() status code = \(response!.statusCode)")
                }
                completion(channel: nil, error: error)
        }
        
    }
    
    
    func deleteChannel(channelId: String!, completion: (channelId: String!, error: NSError?) -> ()) {
        
        manager.DELETE(String("api/channels/" + channelId), parameters: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            completion(channelId: channelId, error: nil)
            
            }) { (dataTask: NSURLSessionDataTask?, apiError: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("deleteChannel() status code = \(response!.statusCode)")
                }
                completion(channelId: channelId, error: apiError)
        }
        
    }
    
    
    func getChannel(channelId: String!, completion: (channel: Channel?, error: NSError?) -> ()) {
        
        manager.GET(String("api/channels/" + channelId), parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let channel = Channel(dictionary: json)
                completion(channel: channel, error: nil)
            } else {
                completion(channel: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("getChannel() status code = \(response!.statusCode)")
                }
                completion(channel: nil, error: error)
        }
        
    }
    
    
    func streamChannel(channelId: String!, completion: (channel: Channel?, error: NSError?) -> ()) {
        
        manager.GET(String("api/stream/" + channelId), parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let channel = Channel(dictionary: json)
                completion(channel: channel, error: nil)
            } else {
                completion(channel: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("streamChannel() status code = \(response!.statusCode)")
                }
                completion(channel: nil, error: error)
        }
        
    }
    
    func getTweetsForChannel(channelId: String!, completion: (channel: Channel?, error: NSError?) -> ()) {
        
        manager.GET(String("api/tweets/" + channelId), parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let channel = Channel(dictionary: json)
                completion(channel: channel, error: nil)
            } else {
                completion(channel: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("getTweetsForChannel() status code = \(response!.statusCode)")
                }
                completion(channel: nil, error: error)
        }
        
    }
    
    
    func getMyChannels(completion: (channels: [Channel]?, error: NSError?) -> ()) {
        
        manager.GET("api/channels", parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? [NSDictionary] {
                let channels = Channel.channelsWithArray(json)
                completion(channels: channels, error: nil)
            } else {
                completion(channels: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("getMyChannels() status code = \(response!.statusCode)")
                }
                completion(channels: nil, error: error)
        }
        
    }
    
    func getDiscoverChannels(completion: (channels: [Channel]?, error: NSError?) -> ()) {
        
        manager.GET("api/discover", parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? [NSDictionary] {
                let channels = Channel.channelsWithArray(json)
                completion(channels: channels, error: nil)
            } else {
                completion(channels: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("getDiscoverChannels() status code = \(response!.statusCode)")
                }
                completion(channels: nil, error: error)
        }
        
    }
    
    func getAvailableFilters(completion: (filters: Filters?, error: NSError?) -> ()) {
        
        manager.GET("api/filters", parameters: nil, progress: nil, success: { (dataTask: NSURLSessionDataTask, response: AnyObject?) -> Void in
            //debugPrint(response)
            if let json = response as? NSDictionary {
                let filters = Filters(dictionary: json)
                completion(filters: filters, error: nil)
            } else {
                completion(filters: nil, error: NSError(domain: "response error", code: 1, userInfo: nil))
            }
            
            }) { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                let response = dataTask?.response as? NSHTTPURLResponse
                if response != nil {
                    debugPrint("getAvailableFilters() status code = \(response!.statusCode)")
                }
                completion(filters: nil, error: error)
        }
        
    }
}
