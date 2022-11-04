//
//  LogIn.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import LocalAuthentication

struct LogIn: View {
    // @State var username = ""
    @State var password = ""
    @State var email = ""
    @State var badPw = false
    @State var badUsername = false
    @State var badEmail = false
    @State var badCreds = false
    @FocusState private var focusedField:FormFields?
    @EnvironmentObject var globalUser:UserModel
    var inputChecker:InputChecker = .shared
    var appBanner:UIImage? = UIImage(named: "AppBanner")
    var service:UserNetworking = .shared
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    let accent = Color.blue
    var body: some View {
        NavigationView {
            VStack {
                if appBanner != nil {
                    Image(uiImage: appBanner!)
                        .resizable()
                        .scaledToFit()
                        .padding([.bottom, .top])
                } else {
                    Text("Rose Gold Gardens")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("MainColor"))
                }
                
                Group {
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        
                    Text("Log in to your Rose Gold Markets account")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .offset(y: 10)
                        .padding(.bottom)
                }
                
                HStack {
                    Image(systemName: "envelope.circle").foregroundColor((focusedField == FormFields.firstName || focusedField == FormFields.lastName) ? accent : Color.gray)
                    TextField("Email", text: $email)
                    .textContentType(UITextContentType.emailAddress)
                    .focused($focusedField, equals: .email)
                }
                .padding()
                .modifier(CustomTextBubble(isActive: focusedField == .email, accentColor: .blue))
                .padding()
                .alert(isPresented: $badEmail) {
                    Alert(title: Text("Email Address"), message: Text("Your email address is invalid"), dismissButton: .default(Text("OK")))
                }
                
                HStack {
                    Image(systemName: "lock.fill").foregroundColor((focusedField == FormFields.firstName || focusedField == FormFields.lastName) ? accent : Color.gray)
                    
                    SecureField("Password", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                }
                .padding()
                .modifier(CustomTextBubble(isActive: focusedField == .password, accentColor: .blue))
                .padding()
                .alert(isPresented: $badPw) {
                    Alert(title: Text("Incorrect Password"), message: Text("Your password contains invalid characters"), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: ForgotPassword()) {
                    Text("Forgot Password?").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.black)
                }
                
                
                Button("Log In") {
                    guard !self.email.isEmpty else {
                        self.badEmail = true
                        focusedField = .email
                        return
                    }
                    
                    guard inputChecker.isValidEmail(email: self.email) else {
                        self.badEmail = true
                        focusedField = .email
                        return
                    }
                    
                    guard !self.password.isEmpty else {
                        self.badPw = true
                        focusedField = .password
                        return
                    }
                    self.loginWithEmail()
                }
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: Font.Weight.bold))
                .padding()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: 190))
                .padding(.top, 40)
                .alert(isPresented: $badCreds) {
                    Alert(title: Text("Incorrect Credentials"), message: Text("Your username and password combination couldn't be found in our records"), dismissButton: .default(Text("OK")))
                }
                Spacer()
                NavigationLink(destination: Register()) {
                    Text("Don't have an account? \(Text("Sign Up").foregroundColor(.blue))").foregroundColor(.black)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .padding()
            .onAppear() {
                //self.username = service.loadUsernameFromDevice()
                //self.password = service.loadUserPassword()
                
                // if these fields aren't empty, I know that they've logged in before
                //if !self.username.isEmpty, !self.password.isEmpty {
                //    self.scanFaceID()
                //}
            }
        }
    }
    
//    func login() {
//        service.login(username: username.lowercased().filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
//            switch (userData) {
//                case .success(let userRes):
//                    DispatchQueue.main.async {
//                        service.saveUserToDevice(user: userRes.data)
//                        service.saveAccessToken(accessToken: userRes.data.accessToken)
//                        let savedPassword = service.loadUserPassword()
//
//                        if savedPassword.isEmpty {// in the case that we've never saved their pw due to first login attempt
//                            service.saveUserPassword(password: password, username: username)
//                        } else if savedPassword != password { // maybe they've changed their pw
//                            service.updateUserPassword(newPassword: password)
//                        }
//
//                        globalUser.login(serviceUsr: userRes.data)
//                    }
//
//            case .failure(let err):
//                DispatchQueue.main.async {
//                    if err == .badPassword {
//                        self.badCreds = true
//                    }
//                    print(err.localizedDescription)
//                }
//            }
//        }
//    }
    
    func loginWithEmail() {
        service.loginWithEmail(email: email.lowercased().filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
            switch (userData) {
                case .success(let userRes):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: userRes.data)
                        service.saveAccessToken(accessToken: userRes.data.accessToken)
                        let savedPassword = service.loadUserPassword()

                        if savedPassword.isEmpty {// in the case that we've never saved their pw due to first login attempt
                            service.saveUserPassword(password: password, username: userRes.data.username)
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
                    // self.login()
                    // grab their creds from our web server creds if possible
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
