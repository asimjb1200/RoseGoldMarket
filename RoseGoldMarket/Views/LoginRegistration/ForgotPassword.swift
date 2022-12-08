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
    
    @State var password = ""
    @State var confirmPassword = ""
    @State var showPW = false
    @State var showConfPW = false
    @State var pwDontMatch = true
    @State var pwNotValid = false

    @State var capLetterFound = false
    @State var numberFound = false
    
    
    @State var firstDigit = ""
    @State var secondDigit = ""
    @State var thirdDigit = ""
    @State var fourthDigit = ""
    @State var fifthDigit = ""
    @State var sixthDigit = ""
    
    @FocusState var formField:FormFields?
    let accent = Color.blue
    var userService:UserNetworking = .shared
    

    var body: some View {
        VStack {
            // MARK: Enter Email
            if codeReceived == false {
                Group {
                    Text("Forgot Password")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                        .alert(isPresented: $errorOccurred) {
                            Alert(title: Text("An Error Occurred"), message: Text("We ran into a problem on our end. Try again later."), dismissButton: .default(Text("OK")))
                        }
                    
                    Text("Enter your email for the verification process, we will send a 4 digit code to your email.")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    
                    HStack {
                        Image(systemName: "envelope.circle").foregroundColor(formField == FormFields.email ? accent : Color.gray)
                        TextField("Email", text: $email)
                            .textContentType(UITextContentType.emailAddress)
                            .autocapitalization(.none)
                            .focused($formField, equals: .email)
                    }
                    .padding()
                    .modifier(CustomTextBubble(isActive: formField == .email, accentColor: .blue))
                    .padding()
                    
                    Button("Continue") {
                        userService.sendUsernameAndEmailForPasswordRecovery(email: email.trimmingCharacters(in: .whitespacesAndNewlines)) {(secCodeResponse) in
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
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25).fill(accent)
                    )
                }
            }

            // MARK: Enter Code
            if codeReceived && codesMatch == false {
                Group {
                    Text("Enter 6 Digit Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    
                    Text("Enter the 6 digit code that you received in your email")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    
                    HStack {
                        TextField("", text: $firstDigit)
                            .modifier(SecurityCodeTextBox(textCode: $firstDigit))
                            
                        TextField("", text: $secondDigit)
                            .modifier(SecurityCodeTextBox(textCode: $secondDigit))
                            
                        TextField("", text: $thirdDigit)
                            .modifier(SecurityCodeTextBox(textCode: $thirdDigit))

                        TextField("", text: $fourthDigit)
                            .modifier(SecurityCodeTextBox(textCode: $fourthDigit))

                        TextField("", text: $fifthDigit)
                            .modifier(SecurityCodeTextBox(textCode: $fifthDigit))

                        TextField("", text: $sixthDigit)
                            .modifier(SecurityCodeTextBox(textCode: $sixthDigit))
                    }.multilineTextAlignment(.center)
                    
                    Button("Continue") {
                        let code = "\(firstDigit)\(secondDigit)\(thirdDigit)\(fourthDigit)\(fifthDigit)\(sixthDigit)"
                        if code == securityCodeFromServer {
                            self.codesMatch = true
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25).fill(accent)
                    )
                }
            }

            // MARK: Passwords
            if codesMatch {
                Group {
                    Text("Reset Password")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    
                    Text("Set the new password for your account so you can login.")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    
                    if showPW == false {
                        HStack(spacing: 0.0) {
                            Image(systemName: "key.fill").foregroundColor(formField == FormFields.password ? accent : Color.gray)
                            SecureField(" Password", text: $password)
                                .onChange(of: password) {
                                    self.capLetterFound = false
                                    self.numberFound = false
                                    for char in $0 {
                                        if char.isUppercase {
                                            self.capLetterFound = true
                                        }
                                        if char.isNumber {
                                            self.numberFound = true
                                        }
                                    }
                                    
                                    password = String($0.prefix(20)) // this limits the char field to 20 chars
                                }
                                .textInputAutocapitalization(.never)
                                .foregroundColor(formField == FormFields.password ? accent : Color.gray)
                                .disableAutocorrection(true)
                                .textContentType(UITextContentType.newPassword)
                                .focused($formField, equals: .password)
                                .onSubmit {
                                    formField = .confirmPassword
                                }

                            Image(systemName: "eye")
                                .foregroundColor(formField == FormFields.password ? accent : Color.gray)
                                .onTapGesture {
                                    showPW.toggle()
                                    formField = FormFields.passwordPlain
                                }
                        }
                        .padding()
                        .modifier(CustomTextBubble(isActive: formField == FormFields.password, accentColor: .blue))
                        .padding([.leading, .trailing, .top], 15.0)
                        
                    } else {
                        HStack(spacing: 0.0) {
                            Image(systemName: "key.fill").foregroundColor(formField == FormFields.passwordPlain ? accent : Color.gray)
                            TextField(" Password", text: $password)
                                .onChange(of: password) {
                                    self.capLetterFound = false
                                    self.numberFound = false
                                    for char in $0 {
                                        if char.isUppercase {
                                            self.capLetterFound = true
                                        }

                                        if char.isNumber {
                                            self.numberFound = true
                                        }
                                        
                                        // get the prompts to disappear if they're visible
                                        //if self.numberFound && self.capLetterFound {
                                            // pwNotValid = false
                                        //}
                                    }

                                    password = String($0.prefix(20)) // this limits the char field to 16 chars
                                }
                                .textInputAutocapitalization(.never)
                                .foregroundColor(formField == FormFields.passwordPlain ? accent : Color.gray)
                                .disableAutocorrection(true)
                                .textContentType(UITextContentType.newPassword)
                                .focused($formField, equals: .passwordPlain)
                                .onSubmit {
                                    formField = .confirmPassword
                                }
                            
                            Image(systemName: "eye.fill")
                                .foregroundColor(formField == FormFields.password ? accent : Color.gray)
                                .onTapGesture {
                                    showPW.toggle()
                                    formField = FormFields.password
                                }
                        }
                        .padding()
                        .modifier(CustomTextBubble(isActive: formField == FormFields.password, accentColor: .blue))
                        .padding([.leading, .trailing, .top])
                    }
                    
                    if showConfPW == false {
                        HStack(spacing: 0.0) {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(formField == FormFields.confirmPassword ? accent : Color.gray)
                                .disableAutocorrection(true)
                                .textContentType(UITextContentType.newPassword)
                                .focused($formField, equals: .confirmPassword)
                                

                            Image(systemName: "eye")
                                .foregroundColor(formField == FormFields.confirmPassword ? accent : Color.gray)
                                .onTapGesture {
                                    showConfPW.toggle()
                                    formField = FormFields.confirmPasswordPlain
                                }
                        }
                        .padding()
                        .modifier(CustomTextBubble(isActive: formField == FormFields.confirmPassword, accentColor: .blue))
                        .padding([.leading, .trailing, .top])
                        .alert(isPresented: $pwDontMatch) {
                            Alert(title: Text("Passwords Don't Match"))
                        }
                    } else {
                        HStack(spacing: 0.0) {
                            TextField("Confirm Password", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(formField == FormFields.confirmPasswordPlain ? accent : Color.gray)
                                .disableAutocorrection(true)
                                .textContentType(UITextContentType.newPassword)
                                .focused($formField, equals: .confirmPasswordPlain)

                            Image(systemName: "eye.fill")
                                .foregroundColor(formField == FormFields.confirmPasswordPlain ? accent : Color.gray)
                                .onTapGesture {
                                    showConfPW.toggle()
                                    formField = FormFields.confirmPassword
                                }
                        }
                        .padding()
                        .modifier(CustomTextBubble(isActive: formField == FormFields.confirmPasswordPlain, accentColor: .blue))
                        .padding([.leading, .trailing, .top])
                        .alert(isPresented: $pwDontMatch) {
                            Alert(title: Text("Passwords Don't Match"))
                        }
                    }
                    
                    Button("Continue") {
                        guard password == confirmPassword else {
                            print("passwords dont match")
                            return
                        }
                        
                        // kick off the password reset process
                    }
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25).fill(accent)
                    )
                }
            }

            
//            NavigationLink(destination: ResetPassword(username: username, email: email, securityCode: self.securityCodeFromServer), isActive:
//                            $codesMatch) {EmptyView()}
        }
    }
}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword()
    }
}
