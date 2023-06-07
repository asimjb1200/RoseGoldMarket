//
//  AppTabContext.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/3/23.
//

import Foundation

class PopToRoot: ObservableObject {
    @Published var navToHome = false
    @Published var selectedTab: Int = 0
}
