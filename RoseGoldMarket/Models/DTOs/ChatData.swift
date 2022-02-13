//
//  ChatData.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/6/22.
//

import Foundation

struct ChatData: Codable, Hashable, Identifiable {
    let customId = UUID()
    let id: UInt
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: Date
    let senderUsername: String
    let receiverUsername: String
}

struct ChatFromBackend: Codable, Hashable, Identifiable {
    let customId = UUID()
    let id: UInt
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: Date
}
