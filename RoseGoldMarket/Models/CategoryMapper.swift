//
//  CategoryMapper.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation
struct CategoryMapper {
    let categories: [UInt: String] = [
        0: "indoor",
        1: "outdoor",
        2: "tropical",
        3: "lowlight"
    ]
}

struct Category: Identifiable {
    var id = UUID()
    var category: UInt
    var isActive: Bool
}
