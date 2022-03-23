//
//  LogIn.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI

struct LogIn: View {
    @State var username = ""
    @State var password = ""
    @EnvironmentObject var globalUser:UserModel
    var service:UserNetworking = .shared
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            TextField("Password", text: $password)
            Button("Log In") {
                self.login()
            }
        }
        .padding()
    }
    
    func login() {
        service.login(username: username, pw: password) { userData in
            switch (userData) {
                case .success(let user):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: user)
                        service.saveAccessToken(accessToken: user.accessToken)
                        globalUser.login(serviceUsr: user)
                    }
                
            case .failure(let err):
                DispatchQueue.main.async {
                    print(err.localizedDescription)
                }
            }
        }
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
    }
}
