//
//  RoseGoldMarketApp.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

@main
struct RoseGoldMarketApp: App {
    @State var firstAppear = true
    @State var isLoading = true
    @StateObject var user:UserModel = .shared
    var body: some Scene {
        WindowGroup {
            if user.isLoggedIn {
                ContentView()
                    .environmentObject(user)
            } else {
                if self.isLoading {
                    Text("Loading...")
                    .onAppear(){
                        if user.isLoggedIn == false {
                            self.startUpStuff()
                        }
                    }
                } else {
                    LogIn()
                        .environmentObject(user)
                }
            }
        }
    }
}

extension RoseGoldMarketApp {
    func startUpStuff() {
        // check for a user in user defaults storage
        let storedUser:ServiceUser? = UserNetworking.shared.loadUserFromDevice()
        if storedUser != nil {
            user.username = storedUser!.username
            user.accountId = storedUser!.accountId
            user.avatarUrl = storedUser!.avatarUrl
            
            // now search for the user's access token from the keychain
            let storedAccessToken = UserNetworking.shared.loadAccessToken()
            guard let storedAccessToken = storedAccessToken else {
                return
            }
            user.accessToken = storedAccessToken

            user.isLoggedIn = true
            self.isLoading = false
        } else {
            // user.isLoggedIn = false
            self.isLoading = false
        }
    }
}
