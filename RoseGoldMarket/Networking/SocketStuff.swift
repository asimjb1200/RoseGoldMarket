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
    let manager = SocketManager(socketURL: URL(string: "https://rosegoldgardens.com/api")!, config: [.log(true), .compress])
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    let userService:UserNetworking = .shared
    
    private init() {
        // handle the UTC date type that will be coming through the wire
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
        
        // grab the user's account id from the device which was saved on login and connect if it's a valid one
        let userAccountId = userService.loadAccountId()
        if userAccountId != 0 {
            self.connectToServer(withId: userAccountId)
        }
        
        manager.defaultSocket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
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
}
