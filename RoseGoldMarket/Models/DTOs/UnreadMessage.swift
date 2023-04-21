//
//  UnreadMessag.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 4/20/23.
//

import Foundation

struct UnreadMessage: Codable, Hashable, Identifiable {
    let message_id: UUID
    let senderid: UInt
    let recid: UInt
    var id: UUID { // computed property so that I can use message_id as my identifiable property
        message_id
    }
}
