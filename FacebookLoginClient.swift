//
//  FacebookLoginClient.swift
//  TeeVee
//
//  Created by Jerry on 3/25/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginClient {
    let facebookReadPermissions = ["public_profile"]
    
    static let sharedInstance = FacebookLoginClient()
    
    func loginToFacebookWithSuccess(fromViewController: UIViewController, successBlock: (User?) -> (), andFailure failureBlock: (NSError?) -> ()) {
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: fromViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                // Error
                FBSDKLoginManager().logOut()
                failureBlock(error)
            } else if result.isCancelled {
                // Cancel
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let grantedPermissions = Array(result.grantedPermissions).map( {"\($0)"} )
                for permission in self.facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    // Do work
                     let fbToken = result.token.tokenString
                     //let fbUserID = result.token.userID
                    
                    //Send fbToken and fbUserID to your web API for processing
                    ChannelClient.sharedInstance.authenticateFacebook(fbToken, completion: { (user, error) in
                        if error != nil {
                            failureBlock(error)
                        } else {
                            successBlock(user)
                        }
                    })
                    
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    failureBlock(nil)
                }
            }
        })
    }
    
    // not used, this will be handled server-side
//    func getUserData(completion: (User?) -> ()) {
//        let FBGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,id"])
//        FBGraphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
//            let name = result["name"] as! String
//            let id = result["id"] as! String
//            let picture = "https://graph.facebook.com/\(id)/picture?type=large"
//            
//            let dictionary = ["name": name, "username": id, "imageurl": picture] as NSDictionary
//            let user = User(dictionary: dictionary)
//            completion(user)
//        })
//    }
}
