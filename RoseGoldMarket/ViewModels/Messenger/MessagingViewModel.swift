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
    let decoder = JSONDecoder()
    let iso8601DateFormatter = ISO8601DateFormatter()
    let encoder = JSONEncoder()
    let dateFormatter = DateFormatter()
    let manager = SocketManager(socketURL: URL(string: "http://localhost:4000")!, config: [.log(true), .compress])
    let socket:SocketUtils = .shared
    @Published var listOfChats:[ChatData] = []
    
    init() {
        print("message view model initialzied")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        iso8601DateFormatter.timeZone = TimeZone.current
        listenForNewMessages()
        //setUpSocket(accountIdForSocket: 16)
    }
    
    func listenForNewMessages() {
        DispatchQueue.main.async {
            self.socket.manager.defaultSocket.on("Private Message") { data, ack in
                print("we got a new message")
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
                    
//                    guard let chatThreadOfTwoUsers = self.allChats[String(chatBlock.senderid)] else {
//                        print("couldn't find their history, which is weird because it should've been created now")
//                        return
//                    }
//                    
//                    // grab the last chat block between the two users
//                    guard let newChatToAdd = chatThreadOfTwoUsers.last else {
//                        print("couldn't unwrap the new chat")
//                        return
//                    }
                    
//                    if !self.uniqueChats.isEmpty {
//                        // find index of the chat that has the sender's username to see if there's already a message involving them
//                        let sendersLastMsgIndex = self.uniqueChats.firstIndex(where: {$0.senderUsername == chatBlock.senderUsername || $0.receiverUsername == chatBlock.senderUsername })
//                        
//                        if let sendersLastMsgIndex = sendersLastMsgIndex {
//                            // now update the last message between these two users
//                            self.uniqueChats[sendersLastMsgIndex] = newChatToAdd
//                        } else {
//                            // if that user wasn't in the array, add them at the end
//                            self.uniqueChats.append(newChatToAdd)
//                        }
//                        
//                        // now to filter the messages by their timestamp, with the most recent stamp being at the front
//                        
//                    } else {
//                        for (_, chatHistory) in self.allChats {
//                            self.uniqueChats.append(chatHistory.last!)
//                            // add check later that doesn't just kill and rebuild the entire list
//                        }
//                    }
                    
                } catch let err {
                    print(err)
                }
            }
        }
    }
    
    func getAllMessages() {
        MessagingService().fetchAllThreadsForUser(userId: 16, completion: { chatResponse in
            switch(chatResponse) {
                case .success(let chatData):
                    DispatchQueue.main.async {
                        // extract the last chat message from each key of the dict to use as a preview
//                        for (_, chatHistory) in chatData {
//                            self.uniqueChats.append(chatHistory.last!)
//                        }
//
//                        // make sure the unique chats are in descending order (by date. I want the newest message at top)
//                        self.uniqueChats = self.uniqueChats.sorted(by: {$0.timestamp > $1.timestamp})

                        self.allChats = chatData
                        
                        // go through each key and sort them by their time stamps in ascending order (I want the oldest message at top)
                        for (accountId, chatHistory) in self.allChats {
                            self.allChats[accountId] = chatHistory.sorted(by: {$0.timestamp < $1.timestamp})
                        }
                    }
                
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                    }
            }
        })
    }
    
    func connectToServer(withId: UInt) {
        // server needs the account to be in a string format to create its key
        let accountIdString = String(withId)
        manager.defaultSocket.connect(withPayload: ["accountId": accountIdString])
    }
    
    func sendMessageToUser(newMessage: String, receiverId: UInt, receiverUsername: String, senderUsername: String, senderId: UInt) {
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
            }
            
            // send the data through the socket, which will save it to the db
            socket.manager.defaultSocket.emit("Private Message", jsonString)
        } catch let err {
            print(err)
        }
        
    }
}
