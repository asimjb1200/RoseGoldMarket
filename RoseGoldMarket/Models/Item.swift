//
//  Item.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation

struct Item: Codable, Hashable {
    let id: UInt
    let name: String
    let description: String
    let owner: UInt
    let isavailable: Bool
    let pickedup: Bool
    let dateposted: Date
    let categories: [String]
    let image1: String
    let image2: String
    let image3: String
}
