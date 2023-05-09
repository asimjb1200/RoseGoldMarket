//
//  LoginTextBoxes.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/8/23.
//

import SwiftUI
import LocalAuthentication
import FacebookShare
import Social

struct LoginTextBoxes: View {
    @Binding var email: String
    @Binding var password: String
    @FocusState var focusedField: FormFields?
    @State var badPw: Bool = false
    @State var badCreds: Bool = false
    @State var badEmail: Bool = false
    @EnvironmentObject var appViewState: CurrentAppView
    @EnvironmentObject var globalUser: UserModel
    @State var loading = false
    var service:UserNetworking = .shared
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    let accent = Color.blue
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "envelope.circle").foregroundColor(focusedField == FormFields.email ? accent : Color.gray)
                TextField("Email", text: $email)
                    .textContentType(UITextContentType.emailAddress)
                    .focused($focusedField, equals: .email)
            }
            .padding()
            .modifier(CustomTextBubble(isActive: focusedField == .email, accentColor: .blue))
            .padding()
            .padding([.leading, .trailing])
            .alert(isPresented: $badEmail) {
                Alert(title: Text("Email Address"), message: Text("Your email address is invalid"), dismissButton: .default(Text("OK")))
            }
            
            HStack {
                Image(systemName: "lock.fill").foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
            }
            .padding()
            .modifier(CustomTextBubble(isActive: focusedField == .password, accentColor: .blue))
            .padding()
            .padding([.leading, .trailing])
            .alert(isPresented: $badPw) {
                Alert(title: Text("Incorrect Password"), message: Text("Your password contains invalid characters"), dismissButton: .default(Text("OK")))
            }
            
            Button(
                action: {
                    withAnimation {
                        appViewState.currentView = .ForgotPassword
                    }
                },
                label: {
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.blue)
                        .padding(.trailing)
                        .padding(.top, -8)
                        .padding(.bottom)
                }
            )
            
            if loading {
                ProgressView()
            } else {
                Button(
                    action: {
                        guard !self.email.isEmpty else {
                            self.badEmail = true
                            focusedField = .email
                            return
                        }
                        
                        guard Validators.isValidEmail(email: self.email) else {
                            self.badEmail = true
                            focusedField = .email
                            return
                        }
                        
                        guard !self.password.isEmpty else {
                            self.badPw = true
                            focusedField = .password
                            return
                        }
                        focusedField = nil
                        self.loginWithEmail()
                    },
                    label: {
                        Text("Log In")
                            .foregroundColor(Color.white)
                            .frame(width: buttonWidth)
                            .font(.system(size: 16, weight: Font.Weight.bold))
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth))
                            .padding(.top)
                            .alert(isPresented: $badCreds) {
                                Alert(title: Text("Incorrect Credentials"), message: Text("Your username and password combination couldn't be found in our records"), dismissButton: .default(Text("OK")))
                            }
                })
            }
        }
    }
}

extension LoginTextBoxes {
    func loginWithEmail() {
        self.loading = true
        service.loginWithEmail(email: email.lowercased().filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
            switch (userData) {
                case .success(let userRes):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: userRes.data)
                        service.saveAccessToken(accessToken: userRes.data.accessToken)

                        self.loading = false
                        globalUser.login(serviceUsr: userRes.data)
                    }
                
            case .failure(let err):
                DispatchQueue.main.async {
                    self.loading = false
                    if err == .badPassword {
                        print("bad pw error")
                        self.badPw = true
                    } else {
                        self.badCreds = true
                    }
                    print(err.localizedDescription)
                }
            }
        }
    }
}

struct LoginTextBoxes_Previews: PreviewProvider {
    static var previews: some View {
        LoginTextBoxes(email: Binding.constant(""), password: Binding.constant("")).environmentObject(UserModel.shared).environmentObject(CurrentAppView())
    }
}
