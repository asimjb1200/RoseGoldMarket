//
//  ChatData.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/6/22.
//

import Foundation

struct ChatData: Codable, Hashable, Identifiable {
    let id: UUID
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: Date
    let senderUsername: String
    let receiverUsername: String
}

struct ChatFromBackend: Codable, Hashable, Identifiable {
    let id: UUID
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: Date
}

struct ChatForSocketTransfer: Codable, Identifiable {
    let id: UUID
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: String
}
