//
//  ResponseFromServer.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/30/22.
//

import Foundation

struct ResponseFromServer<T: Codable>: Codable {
    let data: T
    let error: [String]
}
