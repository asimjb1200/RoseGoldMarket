//
//  AppDelegate.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/30/23.
//

import Foundation
import SwiftUI
import FBSDKCoreKit

/// This delegate  allows swift ui to tap into key app lifecycle events and will allow me to run code there if I need to
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        // Override point for customization after application launch.
        Settings.shared.isAdvertiserTrackingEnabled = false
        Settings.shared.isAutoLogAppEventsEnabled = false
        Settings.shared.isAdvertiserIDCollectionEnabled = false
        
        // allow user to reply to chat messages during notifications
//        let replyToNewMessageAction = UNTextInputNotificationAction(identifier: "REPLY_TO_MESSAGE", title: "Reply")
        
        // define the notification type
//        let newMessageCategory =
//            UNNotificationCategory(
//                identifier: "MESSAGE",
//                actions: [replyToNewMessageAction],
//                intentIdentifiers: [],
//                hiddenPreviewsBodyPlaceholder: ""
//            )
        
        // register the notification type
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.setNotificationCategories([newMessageCategory])
        
        return true
    }
          
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    //No callback in simulator
    //-- must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // convert the token to a hex string
        // let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        // set the object that I want to handle notifications for me
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.delegate = AppNotificationDelegate.shared
        
        // send a notification to subscribers that are listening for the .deviceTokenReceived notification
        // NotificationCenter.default.post(name: .deviceTokenReceived, object: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Couldn't \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("notification: \(userInfo)")
        
        //completionHandler()
    }
}
