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
    @State var badPw = false
    @State var badUsername = false
    @State var badCreds = false
    @EnvironmentObject var globalUser:UserModel
    var service:UserNetworking = .shared
    var body: some View {
        NavigationView {
            VStack {
                Text("RoseGold Marketplace")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("MainColor"))
                TextField("Username", text: $username)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("AccentColor"))
                )
                .padding()
                .alert(isPresented: $badUsername) {
                    Alert(title: Text("Username"), message: Text("Your username contains invalid characters"), dismissButton: .default(Text("OK")))
                }
                
                SecureField("Password", text: $password)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("AccentColor"))
                )
                .padding()
                .alert(isPresented: $badPw) {
                    Alert(title: Text("Incorrect Password"), message: Text("Your password contains invalid characters"), dismissButton: .default(Text("OK")))
                }
                
                
                Button("Log In") {
                    guard !self.username.isEmpty else {
                        self.badUsername = true
                        return
                    }
                    
                    guard !self.password.isEmpty else {
                        self.badPw = true
                        return
                    }
                    self.login()
                }
                .padding()
                .alert(isPresented: $badCreds) {
                    Alert(title: Text("Incorrect Credentials"), message: Text("Your username and password combination couldn't be found in our records"), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink("Register", destination: Register())
            }
            .padding()
        }
    }
    
    func login() {
        service.login(username: username.filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
            switch (userData) {
                case .success(let user):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: user)
                        service.saveAccessToken(accessToken: user.accessToken)
                        globalUser.login(serviceUsr: user)
                    }
                
            case .failure(let err):
                DispatchQueue.main.async {
                    if err == .badPassword {
                        self.badCreds = true
                    }
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
