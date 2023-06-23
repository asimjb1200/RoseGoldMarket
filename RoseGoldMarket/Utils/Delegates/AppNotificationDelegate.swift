//
//  AppNotificationDelegate.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/13/23.
//

import Foundation
import UserNotifications


final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AppNotificationDelegate()
    let userService: UserNetworking = .shared
    let messenger: MessagingService = MessagingService()
    
    // this method will only be called if they decide to reply through the notification bar
    @MainActor // make sure all code run in this method happens on the main thread
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse
           // withCompletionHandler completionHandler: @escaping () -> Void
    ) async {
        // get the id of the message sender from the original notification
        let addtlDataFromBackend = response.notification.request.content.userInfo
        if response.notification.request.content.categoryIdentifier == "MESSAGE" {
            if let textResponse = response as? UNTextInputNotificationResponse {
                let replyText = textResponse.userText
                
                let senderUsername = response.notification.request.content.title
                let messageSenderID = addtlDataFromBackend["messageSenderId"] as! UInt
                //let viewingUserID = addtlDataFromBackend["viewingUserId"] as! UInt
                let messageID = addtlDataFromBackend["messageId"] as! String
                
                // load the access token from the device
                let viewingUserAccount = userService.loadAccountId()
                
                if let accessToken = userService.loadAccessToken() {
                    let viewingUserUsername = userService.loadUsernameFromDevice()
                    
                    // build the `ChatData` object for transfer to the backend for submittal to the other user
                    let chatBlock = ChatData(id: UUID(), senderid: viewingUserAccount, recid: messageSenderID, message: replyText, timestamp: Date(), senderUsername: viewingUserUsername, receiverUsername: senderUsername)
                    
                    // set up an encoder to properly encode the date to a format my server understands
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    
                    do {
                        // send the reply to the viewed notification's message to server for processing
                        let _ = try await messenger.sendNotificationReply(chatData: chatBlock, accessToken: accessToken)
                    } catch let err {
                        print(err.localizedDescription)
                    }
                } else {
                    print("couldnt get access token :(")
                }
            }
        }
        //completionHandler() not needed in async version
    }
}
