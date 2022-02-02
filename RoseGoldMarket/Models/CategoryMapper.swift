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
        3: "low light",
        4: "herbs",
        5: "trees",
        6: "climbers",
        7: "creepers",
        8: "ferns",
        9: "flowering plants",
        10: "plants with seeds"
    ]
}

struct Category: Identifiable {
    var id = UUID()
    var category: UInt
    var isActive: Bool
}
