//
//  User.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import Foundation
import SwiftUI


class UserModel: ObservableObject, UserProtocol {
    private var userService: UserNetworking = .shared
    static let shared:UserModel = UserModel(username: "", accessToken: "", accountId: 0, avatarUrl: "")
    
    @Published var isLoggedIn = false
    
    var username: String
    var accessToken: String {
        didSet {
            userService.saveAccessToken(accessToken: accessToken) // this way everytime the access token is set, we save it to the device
        }
    }
    var accountId: UInt
    var avatarUrl: String
    
    let socket:SocketUtils = .shared
    let decoder = JSONDecoder()

    private init (username:String, accessToken:String, accountId:UInt, avatarUrl:String) {
        self.username = username
        self.accessToken = accessToken
        self.accountId = accountId
        self.avatarUrl = avatarUrl
    }
    
    func login(serviceUsr: ServiceUser) {
        self.username = serviceUsr.username
        self.accessToken = serviceUsr.accessToken
        self.accountId = serviceUsr.accountId
        self.avatarUrl = serviceUsr.avatarUrl
        socket.connectToServer(withId: serviceUsr.accountId)
        withAnimation {
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        socket.disconnectFromServer(accountId: self.accountId)
        self.userService.logout()
        self.username = ""
        self.accountId = 0
        self.avatarUrl = ""
        self.isLoggedIn = false
        print("[UserModel] logout complete")
    }
    
    func updateUserName(newUsername: String) {
        self.username = newUsername
    }
}

protocol UserProtocol {
    var avatarUrl: String { get }
    var username: String { get }
    var accessToken: String { get }
    var accountId: UInt {get}
}
