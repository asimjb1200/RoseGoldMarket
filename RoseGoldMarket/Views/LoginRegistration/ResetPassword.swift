//
//  ResetPassword.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/19/22.
//

import SwiftUI

struct ResetPassword: View {
    @Environment(\.dismiss) private var dismiss
    var username:String
    var email:String
    var securityCode:String
    var service:UserNetworking = .shared
    
    @State var newPassword = ""
    @State var newPasswordAgain = ""
    @State var passwordsDontMatch = false
    @State var passwordNotComplex = false
    
    @State var dataPosted = false
    @State var errOccurred = false
    
    var body: some View {
        VStack {
            Text("New password must contain at least one uppercase letter and at least one number to be valid.").padding().alert(isPresented: $errOccurred) {
                Alert(title: Text("A problem occurred"), message: Text("Try again later."))
            }
            
            SecureField("New Password", text: $newPassword)
                .padding()
                .alert(isPresented: $passwordNotComplex) {
                    Alert(title: Text("Not Complex Enough"), message: Text("Your password must contain at least one uppercase letter and one number."))
                }
            
            SecureField("New Password Again", text: $newPasswordAgain)
                .padding()
                .alert(isPresented: $passwordsDontMatch) {
                    Alert(title: Text("The Passwords Don't Match"))
                }
            
            
            Button("Reset Password") {
                guard newPassword == newPasswordAgain else {
                    passwordsDontMatch = true
                    return
                }
                
                guard pwContainsUppercase(text: newPassword) else {
                    passwordNotComplex = true
                    return
                }
                
                guard pwContainsNumber(text: newPassword) else {
                    passwordNotComplex = true
                    return
                }
                
                postNewPassword()
            }.padding().alert(isPresented: $dataPosted) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text("You may now log in with your new password."),
                    dismissButton:
                            .default(
                                Text("OK"),
                                action: { dismiss() }
                            )
                )
            }
        }.padding()
    }
    
    func pwContainsUppercase(text:String) -> Bool {
        var uppercaseFound = false
        for chr in text {
            if chr.isUppercase {
                uppercaseFound = true
                break
            }
        }
        return uppercaseFound
    }
    
    func pwContainsNumber(text:String) -> Bool {
        var numberFound = false
        for chr in text {
            if chr.isNumber {
                numberFound = true
                break
            }
        }
        return numberFound
    }
    
    func postNewPassword() {
        service.postNewPassword(securityCode: self.securityCode, newPassword: self.newPassword) { serverResponse in
            switch serverResponse {
                case .success(let text):
                    DispatchQueue.main.async {
                        if text == "OK" {
                            self.dataPosted = true
                        } else {
                            self.errOccurred = true
                        }
                    }
                
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err.localizedDescription)
                        self.errOccurred = true
                    }
            }
        }
    }
}

struct ResetPassword_Previews: PreviewProvider {
    static var previews: some View {
        ResetPassword(username: "simtank97", email: "asimjbrown@gmail.com", securityCode: "")
    }
}
