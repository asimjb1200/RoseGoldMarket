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
    var userService:UserNetworking = .shared
    
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)

    var body: some View {
        VStack {
            Text("Enter Your Username and Email Address")
                .alert(isPresented: $errorOccurred) {
                    Alert(title: Text("An Error Occurred"), message: Text("We ran into a problem on our end. Try again later."), dismissButton: .default(Text("OK")))
                }
            
            TextField("", text: $username).padding().modifier(PlaceholderStyle(showPlaceHolder: username.isEmpty, placeHolder: "Username..."))
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                .textInputAutocapitalization(.never)
            
            TextField("", text: $email).padding().modifier(PlaceholderStyle(showPlaceHolder: email.isEmpty, placeHolder: "Email..."))
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                .textInputAutocapitalization(.never)
            
            Button("Send Code") {
                userService.sendUsernameAndEmailForPasswordRecovery(username: username, email: email) {(secCodeResponse) in
                    switch(secCodeResponse) {
                        case .success(let securityResponse):
                            DispatchQueue.main.async {
                                self.securityCodeFromServer = securityResponse.data
                                self.codeReceived = true
                            }
                        case .failure( _):
                            DispatchQueue.main.async {
                                errorOccurred = true
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
                
                NavigationLink(destination: ResetPassword(username: username, email: email), isActive:
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
