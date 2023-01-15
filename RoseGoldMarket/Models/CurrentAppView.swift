//
//  CurrentAppView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/13/23.
//

import Foundation

class CurrentAppView: ObservableObject {
    @Published var currentView: AppViewStates = .LandingPage
}
