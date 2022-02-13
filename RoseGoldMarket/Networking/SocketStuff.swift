//
//  SocketStuff.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/8/22.
//

import Foundation
import SocketIO

final class SocketUtils: ObservableObject {
    static let shared = SocketUtils()
    let manager = SocketManager(socketURL: URL(string: "http://localhost:4000")!, config: [.log(true), .compress])
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    @Published var newMessage = ""
    @Published var newChat: ChatFromBackend = ChatFromBackend(id: 0, senderid: 0, recid: 0, message: "", timestamp: Date())
    
    private init() {
        // handle the UTC date type that will be coming through the wire
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
        
        manager.defaultSocket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        manager.defaultSocket.on("Private Message") { data, ack in
            do {
                guard let dict = data[0] as? [String: Any] else { return }
                let rawData = try JSONSerialization.data(withJSONObject: dict["data"] as Any, options: [])
                let chatBlock = try self.decoder.decode(ChatFromBackend.self, from: rawData)
                self.newChat = chatBlock
                //self.newMessage = chatBlock.message
            } catch let err {
                print(err)
            }
        }
    }
    
    func connectToServer(withId: UInt) {
        // server needs the account to be in a string format to create its key
        let accountIdString = String(withId)
        manager.defaultSocket.connect(withPayload: ["accountId": accountIdString])
    }
    
    func disconnectFromServer(accountId: UInt) {
        let accountIdString = String(accountId)
        manager.defaultSocket.emit("disconnect me", accountIdString) // remove their socket and key from dict on server
        manager.defaultSocket.disconnect()
    }
    
    func sendMessage(newMessage: ChatData) {
        
    }
}
