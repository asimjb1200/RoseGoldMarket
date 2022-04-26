//
//  User.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import Foundation


class UserModel: ObservableObject, UserProtocol {
    var username: String
    var accessToken: String
    var accountId: UInt
    var avatarUrl: String
    private var userService: UserNetworking = .shared
    static let shared:UserModel = UserModel(username: "", accessToken: "", accountId: 0, avatarUrl: "")
    let socket:SocketUtils = .shared
    @Published var isLoggedIn = false

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
        self.isLoggedIn = true
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
}

protocol UserProtocol {
    var avatarUrl: String { get }
    var username: String { get }
    var accessToken: String { get }
    var accountId: UInt {get}
}
