//
//  AppDelegate.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    
    let subscriptionTopic = "/topics/global"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        registerForPushNotifications(application)
        startGCMService()
        checkIfLaunchedFromPush(application, launchOptions: launchOptions)
        
        Theme.applyTheme()

        //Fabric.with([Twitter.self])
        Fabric.with([Crashlytics.self])
        
        let mixpanel = Mixpanel.sharedInstanceWithToken("f168b59e20299bb584c4149dee9944ed")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        GCMService.sharedInstance().disconnect()
        self.connectedToGCM = false
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        GCMService.sharedInstance().connectWithHandler({(error:NSError?) -> Void in
            if let error = error {
                debugPrint("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                debugPrint("Connected to GCM")
                
                self.subscribeToTopic()
            }
        })
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().postNotificationName(AppWillTerminateNotificationKey, object: self, userInfo: nil)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
       return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {

    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
//        var tokenString = ""
//        
//        for i in 0..<deviceToken.length {
//            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
//        }
//        
//        debugPrint("Device Token:", tokenString)
        
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
        debugPrint("Registration for remote notification failed with error: \(error.localizedDescription)")
        
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(
            registrationKey, object: nil, userInfo: userInfo)
    }

    
    // [START ack_message_reception]
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        debugPrint("Notification received: \(userInfo)")
        
        if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background {
            //opened from a push notification when the app was on background
            debugPrint("Notification received when app was in BACKGROUND")
        }
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message
        
        NSNotificationCenter.defaultCenter().postNotificationName(PushMessageReceivedKey, object: nil,
                                                                  userInfo: userInfo)
    }
    
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        debugPrint("Notification received: \(userInfo)")
        
        if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background {
            //opened from a push notification when the app was on background
            debugPrint("Notification received when app was in BACKGROUND")
        }
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        
        NSNotificationCenter.defaultCenter().postNotificationName(PushMessageReceivedKey, object: nil,
                                                                  userInfo: userInfo)
        handler(UIBackgroundFetchResult.NoData)
    }
    // [END ack_message_reception]
    
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                                                          options: nil, handler: {(error:NSError?) -> Void in
                                                            if let error = error {
                                                                // Treat the "already subscribed" error more gently
                                                                if error.code == 3001 {
                                                                    debugPrint("Already subscribed to \(self.subscriptionTopic)")
                                                                } else {
                                                                    debugPrint("Subscription failed: \(error.localizedDescription)");
                                                                }
                                                            } else {
                                                                self.subscribedToTopic = true;
                                                                NSLog("Subscribed to \(self.subscriptionTopic)");
                                                            }
            })
        }
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            debugPrint("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            debugPrint("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }

    func registerForPushNotifications(application: UIApplication) {
        // Register for remote notifications
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
    }
    
    func startGCMService() {
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
    }
    
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        debugPrint("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    func checkIfLaunchedFromPush(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
        if (notification != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.application(application, didReceiveRemoteNotification: notification! as [NSObject : AnyObject])
            }
        }
    }
}

