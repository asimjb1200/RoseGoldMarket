//
//  MessageListViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation
import SocketIO

final class MessagingViewModel: ObservableObject {
    /// Holds every chat thread that the user is involved in. Each chat thread can be accessed by the recipient's account id. The value that the account id key accesses is a list of chat objects that have been exchanged between the two users
    @Published var allChats: [String:[ChatData]] = [:]
    @Published var firstAppear = true
    @Published var newMsgCount = 0
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
        //listenForNewMessagesV2()
    }

    func listenForNewMessages() {
        DispatchQueue.main.async {
            self.socket.manager.defaultSocket.on("Private Message") { data, ack in
                do {
                    self.newMsgCount += 1
                    guard let dict = data[0] as? [String: Any] else { return }
                    let rawData = try JSONSerialization.data(withJSONObject: dict["data"] as Any, options: [])
                    let chatBlock = try self.decoder.decode(ChatData.self, from: rawData)

                    // check the all chats dict for the sender's key, to see if they have history
                    if self.allChats[String(chatBlock.senderid)] != nil {
                        // if they have history, append the new chat to the end of their convo
                        self.allChats[String(chatBlock.senderid)]!.append(chatBlock)
                    } else {
                        // if not present, I need to create it for them
                        self.allChats[String(chatBlock.senderid)] = [chatBlock]
                    }
                    self.listOfChats = self.buildUniqueChatList()
                } catch let err {
                    print("[MessagingVM] tried to set up private message listener for user: \(err)")
                }
            }
        }
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
                    let otherUsersId = lastMessageInActiveChat.senderid
                    
                    // if the sender of this chat matches the receiver of the first message in the currently active chat..
                    if otherUsersId == newChatBlock.senderid {
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
                            let _ = self.latestMessages.remove(at: sendingUsersIndex)
                            // now build a new chat preview from the ChatData that came from the socket
                            let latestChatPreviewFromSendingUser:ChatDataForPreview = ChatDataForPreview.make(from: newChatBlock)
                            
                            // now add the chat to the top of the list since it's the newest message
                            self.latestMessages.insert(latestChatPreviewFromSendingUser, at: 0)
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
    
    func getAllMessagesInThread(viewingUser:UInt, otherUserAccount:UInt) {
        MessagingService().fetchMessageThreadBetweenUsers(viewingAccountId: viewingUser, otherUserAccountId: otherUserAccount) { threadDataResponse in
            switch threadDataResponse {
                case .success(let threadData):
                    DispatchQueue.main.async {
                        self.currentlyActiveChat = threadData
                    }
                case .failure(let err):
                    print(err)
            }
        }
    }

    func getAllMessages(user:UserModel) {
        MessagingService().fetchAllThreadsForUser(userId: user.accountId, token: user.accessToken, completion: { chatResponse in
            print("[MessagingVM] fetching messages")
            switch(chatResponse) {
                case .success(let chatData):
                    DispatchQueue.main.async {
                        if chatData.newToken != nil {
                            user.accessToken = chatData.newToken!
                        }
                        self.allChats = chatData.data

                        // go through each key and sort them by their time stamps in ascending order (I want the oldest message at top)
                        for (accountId, chatHistory) in self.allChats {
                            self.allChats[accountId] = chatHistory.sorted(by: {$0.timestamp < $1.timestamp})
                        }

                        self.listOfChats = self.buildUniqueChatList()
                    }
                
                case .failure(let err):
                    DispatchQueue.main.async {
                        if err == .tokenExpired {
                            user.logout()
                        }
                        print("[MessagingVM] problem occurred when fetching all msgs for user \(user.accountId): \(err)")
                    }
            }
        })
    }
    
    func getLatestMessages(viewingUser:UInt) {
        MessagingService().fetchLatestMessageInEachChat(userId: viewingUser) { chatData in
            switch chatData {
                case .success(let latestChats) :
                    DispatchQueue.main.async {
                        self.latestMessages = latestChats
                    }
                    
                case .failure(let err):
                    print(err)
            }
        }
    }
    
    func getOtherUsersName(accountId: UInt) {
        MessagingService().getOtherChatParticipantName(accountId: accountId) { usernameResponse in
            switch usernameResponse {
                case .success(let username):
                    print(username)
                case .failure(let err):
                    print(err)
            }
        }
    }

    /// used to build the chat list for the MessageList view. This function will ensure that only the latest message from each of the user's chat threads will be inlcuded in the list.
    /// As a result, you can use the result of this function to display a list of unique chat threads that the viewing user is involved in
    func buildUniqueChatList() -> [ChatData] {
        var tempHolder:[ChatData] = []
        // iterate through allChats
        for(_, chatHistory) in self.allChats {
            tempHolder.append(chatHistory.last!)
        }
        return tempHolder.sorted(by: {$0.timestamp > $1.timestamp})
    }


    /// sends a message to the user via a socket connection
    func sendMessageToUser(newMessage: String, receiverId: UInt, receiverUsername: String, senderUsername: String, senderId: UInt) -> UUID? {
        // build the chat block for the server
        let today = Date()

        let dateString = iso8601DateFormatter.string(from: today)

        let newChatBlockForSocket = ChatForSocketTransfer(id: UUID(), senderid: senderId, recid: receiverId, message: newMessage, timestamp: dateString)
        let newChatBlockForUser = ChatData(id: newChatBlockForSocket.id, senderid: newChatBlockForSocket.senderid, recid: newChatBlockForSocket.recid, message: newMessage, timestamp: today, senderUsername: senderUsername, receiverUsername: receiverUsername)

        // serialize the chat block into a JSON string
        do {
            let encodedData:Data = try encoder.encode(newChatBlockForSocket)
            let jsonString:String = String(data:encodedData, encoding: .utf8)!

            DispatchQueue.main.async {
                // add the new message to the user's chat list on the device
                if self.allChats[String(receiverId)] != nil {
                    self.allChats[String(receiverId)]!.append(newChatBlockForUser)
                } else {
                    self.allChats[String(receiverId)] = [newChatBlockForUser]
                }

                self.listOfChats = self.buildUniqueChatList()
            }
            
            // send the data through the socket, which will save it to the db
            socket.manager.defaultSocket.emit("Private Message", jsonString)
        } catch let err {
            print("[MessagingVM] problem occurred when trying to send message through socket between users (rec)\(receiverId) and (sender)\(senderId): \(err)")
        }
        return newChatBlockForUser.id
    }
}
