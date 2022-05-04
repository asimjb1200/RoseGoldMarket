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
        listenForNewMessages()
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
