//
//  MessageListViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import Foundation
import SocketIO

final class MessagingViewModel: ObservableObject {
    @Published var allChats: [String:[ChatData]] = [:]
    @Published var firstAppear = true
    @Published var newMsgCount = 0
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
                    print(err)
                }
            }
        }
    }

    func getAllMessages(user:UserModel) {
        MessagingService().fetchAllThreadsForUser(userId: user.accountId, token: user.accessToken, completion: { chatResponse in
            print("fetching messages")
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
                        print(err)
                    }
            }
        })
    }

    func buildUniqueChatList() -> [ChatData] {
        var tempHolder:[ChatData] = []
        // iterate through allChats
        for(_, chatHistory) in self.allChats {
            tempHolder.append(chatHistory.last!)
        }
        return tempHolder.sorted(by: {$0.timestamp > $1.timestamp})
    }


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
            print(err)
        }
        return newChatBlockForUser.id
    }
}
