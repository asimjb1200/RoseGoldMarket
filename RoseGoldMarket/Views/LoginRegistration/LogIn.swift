//
//  LogIn.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import LocalAuthentication

struct LogIn: View {
    @State var username = ""
    @State var password = ""
    @State var badPw = false
    @State var badUsername = false
    @State var badCreds = false
    @EnvironmentObject var globalUser:UserModel
    var service:UserNetworking = .shared
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    var body: some View {
        NavigationView {
            VStack {
                Text("RoseGold Marketplace")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("MainColor"))
                TextField("Username", text: $username)
                .modifier(PlaceholderStyle(showPlaceHolder: username.isEmpty, placeHolder: "Username..."))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                .textInputAutocapitalization(.never)
                .alert(isPresented: $badUsername) {
                    Alert(title: Text("Username"), message: Text("Your username contains invalid characters"), dismissButton: .default(Text("OK")))
                }
                
                SecureField("Password", text: $password)
                .modifier(PlaceholderStyle(showPlaceHolder: password.isEmpty, placeHolder: "Password..."))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
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
                
                NavigationLink("Forgot Password", destination: Text("I Forgot My Password"))
            }
            .navigationBarTitle("Welcome")
            .navigationBarHidden(true)
            .padding()
            .onAppear() {
                self.username = service.loadUsernameFromDevice()
                self.password = service.loadUserPassword()
                
                // if these fields aren't empty, I know that they've logged in before
                if !self.username.isEmpty, !self.password.isEmpty {
                    self.scanFaceID()
                }
            }
        }
    }
    
    func login() {
        service.login(username: username.lowercased().filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
            switch (userData) {
                case .success(let userRes):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: userRes.data)
                        service.saveAccessToken(accessToken: userRes.data.accessToken)
                        let savedPassword = service.loadUserPassword()

                        if savedPassword.isEmpty {// in the case that we've never saved their pw due to first login attempt
                            service.saveUserPassword(password: password, username: username)
                        } else if savedPassword != password { // maybe they've changed their pw
                            service.updateUserPassword(newPassword: password)
                        }
                        
                        globalUser.login(serviceUsr: userRes.data)
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
    
    func scanFaceID() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                // authentication has now completed
                if success {
                    // authenticated successfully
                    self.login()
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics so make them manually press login
        }
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
    }
}
