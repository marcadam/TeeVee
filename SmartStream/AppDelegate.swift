//
//  AppDelegate.swift
//  SmartChannel
//
//  Created by Hieu Nguyen on 2/29/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit
import FBSDKCoreKit

let AppWillTerminateNotificationKey = "kAppWillTerminateNotificaton"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
//    let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
//    let myChannelsStoryboard = UIStoryboard(name: "MyChannels", bundle: nil)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

//        let homeVC = homeStoryboard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
//
//        let menuNC = menuStoryboard.instantiateViewControllerWithIdentifier("MenuNavigationController") as! UINavigationController
//        let menuVC = menuNC.topViewController as! MenuTableViewController
//
//        let myChannelsNC = myChannelsStoryboard.instantiateViewControllerWithIdentifier("MyChannelsNavigationController") as! UINavigationController
//        let myChannelsVC = myChannelsNC.topViewController as! MyChannelsViewController
//
//        menuVC.containerViewController = homeVC
//        myChannelsVC.containerViewController = homeVC
//        homeVC.menuViewController = menuNC
//        homeVC.contentViewController = myChannelsVC
//
//        window?.rootViewController = homeVC
//        window?.makeKeyAndVisible()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        registerForPushNotifications(application)
        
        Theme.applyTheme()

        //Fabric.with([Twitter.self])

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().postNotificationName(AppWillTerminateNotificationKey, object: self, userInfo: nil)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
       return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//        if notificationSettings.types != .None {
//            application.registerForRemoteNotifications()
//        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        debugPrint("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        debugPrint("Failed to register:", error)
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
}

