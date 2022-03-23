//
//  ServiceUser.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/16/22.
//

import Foundation

struct ServiceUser: UserProtocol, Codable {
    var avatarUrl: String
    var accountId: UInt
    let username: String
    let accessToken: String
}
