//
//  FacebookLoginClient.swift
//  TeeVee
//
//  Created by Jerry on 3/25/16.
//  Copyright © 2016 SmartStream. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginClient {
    let facebookReadPermissions = ["public_profile"]
    
    static let sharedInstance = FacebookLoginClient()
    
    func loginToFacebookWithSuccess(callingViewController: UIViewController, successBlock: (FBSDKLoginManagerLoginResult?) -> (), andFailure failureBlock: (NSError?) -> ()) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            // return
        }
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: callingViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
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
                    // let fbToken = result.token.tokenString
                    // let fbUserID = result.token.userID
                    
                    //Send fbToken and fbUserID to your web API for processing, or just hang on to that locally if needed
                    //self.post("myserver/myendpoint", parameters: ["token": fbToken, "userID": fbUserId]) {(error: NSError?) ->() in
                    //  if error != nil {
                    //      failureBlock(error)
                    //  } else {
                    //      successBlock(maybeSomeInfoHere?)
                    //  }
                    //}
                    
                    successBlock(result)
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    failureBlock(nil)
                }
            }
        })
    }
}
