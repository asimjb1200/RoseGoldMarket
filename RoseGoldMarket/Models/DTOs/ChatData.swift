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

struct ChatDataForPreview: Codable, Hashable, Identifiable {
    let id: UUID
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: Date
    let nonViewingUsersUsername: String
    
    /// to convert from the chat data object
    static func make(from chatData: ChatData) -> ChatDataForPreview {
        return ChatDataForPreview(
            id: chatData.id,
            senderid: chatData.senderid,
            recid: chatData.recid,
            message: chatData.message,
            timestamp: chatData.timestamp,
            nonViewingUsersUsername: chatData.senderUsername
        )
    }
}

struct ChatForSocketTransfer: Codable, Identifiable {
    let id: UUID
    let senderid: UInt
    let recid: UInt
    let message: String
    let timestamp: String
}
