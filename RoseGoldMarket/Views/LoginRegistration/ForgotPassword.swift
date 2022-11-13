//
//  ForgotPassword.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/26/22.
//

import SwiftUI

struct ForgotPassword: View {
    @State var username:String = ""
    @State var email:String = ""
    @State var securityCodeFromServer = ""
    @State var securityCodeFromUser = ""
    @State var codesMatch = false
    @State var codeReceived = false
    @State var errorOccurred = false
    @State var userNotFound = false
    @FocusState var formField:FormFields?
    var userService:UserNetworking = .shared
    
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)

    var body: some View {
        VStack {
            Text("Enter Your Username and Email Address")
                .alert(isPresented: $errorOccurred) {
                    Alert(title: Text("An Error Occurred"), message: Text("We ran into a problem on our end. Try again later."), dismissButton: .default(Text("OK")))
                }
            
            TextField("Username", text: $username)
                .padding()
                .modifier(CustomTextBubble(isActive: formField == .username, accentColor: .blue))
                .padding()
                .focused($formField, equals: .username)
                .textInputAutocapitalization(.never)
                .alert(isPresented: $userNotFound) {
                    Alert(title: Text("User Not Found"), message: Text("We don't have that user and email combination in our records. Please check your spelling and try again."), dismissButton: .default(Text("OK")))
                }
            
            TextField("Email", text: $email)
                .padding()
                .modifier(CustomTextBubble(isActive: formField == .email, accentColor: .blue))
                .padding()
                .focused($formField, equals: .email)
                .textInputAutocapitalization(.never)
            
            Button("Send Code") {
                userService.sendUsernameAndEmailForPasswordRecovery(username: username.trimmingCharacters(in: .whitespacesAndNewlines), email: email.trimmingCharacters(in: .whitespacesAndNewlines)) {(secCodeResponse) in
                    switch(secCodeResponse) {
                        case .success(let securityResponse):
                            DispatchQueue.main.async {
                                self.securityCodeFromServer = securityResponse.data
                                self.codeReceived = true
                            }
                        case .failure(let err):
                            DispatchQueue.main.async {
                                if err == .userNotFound {
                                    userNotFound = true
                                } else {
                                    errorOccurred = true
                                }
                                
                            }
                    }
                }
            }
            
            if codeReceived {
                Text("An email has been sent to you from support@rosegoldgardens.com that contains a security code. Enter that code into the field below. Be sure to check your spam/junk folders if you don't see the email within a few minutes.").padding()
                
                TextField("6 Digit Code:", text: $securityCodeFromUser).underlineTextField().frame(maxWidth: .infinity, alignment: .center).padding()
                
                Button("Reset Password") {
                    guard securityCodeFromServer == securityCodeFromUser else {
                        
                        return
                    }
                    codesMatch = true
                }
                
                NavigationLink(destination: ResetPassword(username: username, email: email, securityCode: self.securityCodeFromServer), isActive:
                                $codesMatch) {EmptyView()}
            }
        }
    }
}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword()
    }
}
