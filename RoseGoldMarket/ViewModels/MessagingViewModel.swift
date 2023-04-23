//
//  MessageListViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation
import SocketIO

final class MessagingViewModel: ObservableObject {
    @Published var firstAppear = true
    @Published var newMsgCount = 0
    var unreadMessages: [UnreadMessage] = []
    /// Contains unique chats only. it is intended to be used to show a list to the user of each chat they are involved in. For example, if the user has chatted with 'John' and 'Tony' the
    /// list will contain the latest message in each of their respective threads (and ONLY the latest message).
    @Published var listOfChats:[ChatData] = []
    
    /// this list will contain only the latest message from each chat that the user is involved
    @Published var latestMessages: [ChatDataForPreview] = []
    /// this will contain the chat data for the current chat that they're viewing
    @Published var currentlyActiveChat: [ChatData] = []
    let decoder = JSONDecoder()
    let iso8601DateFormatter = ISO8601DateFormatter()
    let encoder = JSONEncoder()
    let dateFormatter = DateFormatter()
    let socket:SocketUtils = .shared
    static let shared = MessagingViewModel()
    
    private init() {
        print("message view model initialzied")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso8601DateFormatter.timeZone = TimeZone.current
        listenForNewMessagesV2()
    }
    
    /// listens for new messages coming in from the socket set up. if the new message is coming from the active chat it will add it there, otherwise it will be added to the latest messages array which serve as the chat preview in the message list view
    func listenForNewMessagesV2() {
        self.socket.manager.defaultSocket.on("Private Message") { data, ack in // anything coming in from this, due to my setup, the viewing user will always be the receiver id. I take care of appending new messages from the user in the code myself
            do {
                guard let dict = data[0] as? [String: Any] else { return }
                let rawData = try JSONSerialization.data(withJSONObject: dict["data"] as Any, options: [])
                let newChatBlock:ChatData = try self.decoder.decode(ChatData.self, from: rawData)
                
                // first let's check to see if the user is currently viewing a convo, if so let's grab the oldest message in it
                if let lastMessageInActiveChat:ChatData = self.currentlyActiveChat.last {
                    let senderOfLastMsgInActiveChat = lastMessageInActiveChat.senderid
                    
                    // if the sender of this chat matches the sender or receiver of the last message in the currently active chat..
                    if senderOfLastMsgInActiveChat == newChatBlock.senderid || senderOfLastMsgInActiveChat == newChatBlock.recid {
                        DispatchQueue.main.async {
                            self.currentlyActiveChat.append(newChatBlock)
                        }
                    }
                } else {
                    /// in this case I know that they dont have a chat open, so just add this new chat block to the chat preview list
                    // check for the sender's id in the current preview list
                    if let sendingUsersIndex = self.latestMessages.firstIndex(where: {$0.senderid == newChatBlock.senderid || $0.recid == newChatBlock.senderid}) {
                        // now remove that chat from the list
                        DispatchQueue.main.async {
                            self.addNewestMessageToChatPreviews(latestChatBlock: newChatBlock, otherUsersIndexInPreviewArray: sendingUsersIndex)
                            self.newMsgCount += 1
                        }
                    } else {
                        // in this case I know that they haven't received a message from this user, so lets just build a chat preview
                        let latestChat = ChatDataForPreview.make(from: newChatBlock)
                        
                        DispatchQueue.main.async {
                            // now add it to the front of the latest messages array
                            self.latestMessages.insert(latestChat, at: 0)
                            self.newMsgCount += 1
                        }
                    }
                }
            } catch let err {
                print("[MessagingVM] tried to set up private message listener for user: \(err)")
            }
        }
    }
    
    func addNewestMessageToChatPreviews(latestChatBlock:ChatData, otherUsersIndexInPreviewArray:Int) {
        // now build a new chat preview from the ChatData that came from the socket
        let latestChatPreviewFromSendingUser:ChatDataForPreview = ChatDataForPreview.make(from: latestChatBlock)
        self.latestMessages[otherUsersIndexInPreviewArray].message = latestChatPreviewFromSendingUser.message
        self.latestMessages[otherUsersIndexInPreviewArray].timestamp = latestChatPreviewFromSendingUser.timestamp
        self.latestMessages[otherUsersIndexInPreviewArray].senderid = latestChatPreviewFromSendingUser.senderid
        self.latestMessages[otherUsersIndexInPreviewArray].recid = latestChatPreviewFromSendingUser.recid
        
        // now put newest messages first
        self.latestMessages.sort { $0.timestamp > $1.timestamp }
    }
    
    /// fetches all of the messages that the user missed while their socket was disconnected
    func getUnreadMessagesForUser(user:UserModel) {
        MessagingService().fetchUnreadMessagesForUser(viewingUserId: user.accountId, token: user.accessToken) { unreadMessagesRes in
            switch unreadMessagesRes {
                case .success(let unreadMessages):
                    DispatchQueue.main.async {
                        print(unreadMessages.data)
                        self.unreadMessages = unreadMessages.data
                        
                        // split the unread messages out by their sender id so that the count can be broken up on a chat by chat basis
                        
                        self.newMsgCount += self.unreadMessages.count
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err.localizedDescription)
                    }
            }
        }
    }
    
    func getAllMessagesInThread(viewingUser:UInt, otherUserAccount:UInt, user:UserModel) {
        MessagingService().fetchMessageThreadBetweenUsers(viewingAccountId: viewingUser, otherUserAccountId: otherUserAccount, token: user.accessToken) { threadDataResponse in
            switch threadDataResponse {
                case .success(let threadData):
                    if threadData.newToken != nil {
                        user.accessToken = threadData.newToken!
                    }
                    DispatchQueue.main.async {
                        self.currentlyActiveChat = threadData.data
                    }
                case .failure(let err):
                    print(err)
            }
        }
    }
    
    func getLatestMessages(viewingUser:UInt, user:UserModel) {
        MessagingService().fetchLatestMessageInEachChat(userId: viewingUser, token: user.accessToken) { chatData in
            switch chatData {
                case .success(let latestChats) :
                    if latestChats.newToken != nil {
                        user.accessToken = latestChats.newToken!
                    }
                    DispatchQueue.main.async {
                        self.latestMessages = latestChats.data
                    }
                    
                case .failure(let err):
                    print(err)
            }
        }
    }

    /// sends a message to the user via a socket connection
    func sendMessageToUserV2(newMessage:String, receiverId:UInt, receiverUsername:String, senderUsername:String, senderId:UInt) -> UUID? {
        let today = Date()
        let dateString = iso8601DateFormatter.string(from: today)
        
        let newChatBlockForSocket = ChatForSocketTransfer(id: UUID(), senderid: senderId, recid: receiverId, message: newMessage, timestamp: dateString)
        let newChatBlockForUser = ChatData(id: newChatBlockForSocket.id, senderid: newChatBlockForSocket.senderid, recid: newChatBlockForSocket.recid, message: newMessage, timestamp: today, senderUsername: senderUsername, receiverUsername: receiverUsername)
        
        do {
            let encodedData:Data = try encoder.encode(newChatBlockForSocket)
            let jsonString:String = String(data:encodedData, encoding: .utf8)!
            
            // send the message through the socket
            socket.manager.defaultSocket.emit("Private Message", jsonString)
            
            // add the message to the user's chat if one is available
            if self.currentlyActiveChat.isEmpty == false {
                DispatchQueue.main.async {
                    self.currentlyActiveChat.append(newChatBlockForUser)
                }
            }
            
            return newChatBlockForUser.id
        } catch let err {
            print("[MessagingVM] problem occurred when trying to send message through socket between users (rec)\(receiverId) and (sender)\(senderId): \(err)")
            return nil
        }
    }
}
