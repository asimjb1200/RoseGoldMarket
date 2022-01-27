//
//  EnumsForAddItemsView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/26/22.
//

import Foundation

enum CategoryIds: UInt, CaseIterable {
    case indoor = 0
    case outdoor = 1
    case tropical = 2
    case lowlight = 3
}

enum AddItemViewStates {
    case noCategory
    case nameEmpty
    case descriptionEmpty
    case imagesEmpty
}
