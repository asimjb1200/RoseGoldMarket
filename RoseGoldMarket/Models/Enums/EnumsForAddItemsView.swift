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
    case herbs = 4
    case trees = 5
    case climbers = 6
    case creepers = 7
    case ferns = 8
    case floweringPlants = 9
    case PlantsWithSeeds = 10
}

enum AddItemViewStates {
    case noCategory
    case nameEmpty
    case descriptionEmpty
    case imagesEmpty
}
