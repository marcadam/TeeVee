//
//  User.swift
//  SmartStream
//
//  Created by Jerry on 3/9/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    let dictionary: NSDictionary
    let name: String?
    let imageUrl: String?
    var pushRegistrationToken: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        var name: String? = ""
        var imageUrl: String? = ""
        
        if let profileDict = dictionary["profile"] as? NSDictionary {
            name = profileDict["name"] as? String
            imageUrl = profileDict["picture"] as? String
        }
        
        self.name = name
        self.imageUrl = imageUrl
        self.pushRegistrationToken = dictionary["push_registration_token"] as? String
    }
    
    class func login(fromViewController: UIViewController?, completion: (error: NSError?) -> ()) {
        FacebookLoginClient.sharedInstance.loginToFacebookWithSuccess(fromViewController, successBlock: { (user: User?) in
            User.currentUser = user

            NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: nil)
            completion(error: nil)
        }) { (error) -> () in
            if error != nil {
                debugPrint(error.debugDescription)
            }
            completion(error: error)
        }
    }
    
    class func relogin(completion: (error: NSError?) -> ()) {
        if FBSDKAccessToken.currentAccessToken() != nil && FBSDKAccessToken.currentAccessToken().tokenString != nil {
            ChannelClient.sharedInstance.authenticateFacebook(FBSDKAccessToken.currentAccessToken().tokenString, completion: { (user, error) in
                if error != nil {
                    debugPrint(error.debugDescription)
                }
                User.currentUser = user
                
                NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: nil)
                completion(error: error)
            })
        }
    }
    
    class func logout() {
        User.currentUser = nil
        FBSDKLoginManager().logOut()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        //print(dictionary)
                        _currentUser = User(dictionary: dictionary)
                    } catch {
                        
                    }
                }
            }
            
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: []) as NSData
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("JSON error")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
