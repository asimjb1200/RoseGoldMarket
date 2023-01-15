//
//  ForgotPassword.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/26/22.
//

import SwiftUI

struct ForgotPassword: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewState: CurrentAppView
    
    @State var email:String = ""
    @State var securityCodeFromUser = ""
    @State var codesMatch = false
    @State var codeReceived = false
    @State var errorOccurred = false
    @State var codeNotFound = false
    @State var userNotFound = false
    
    @State var invalidEmail = false
    
    @State var loading = false
    
    @State var password = ""
    @State var confirmPassword = ""
    @State var showPW = false
    @State var showConfPW = false
    @State var pwDontMatch = false
    @State var pwNotValid = false

    @State var pwNeedsCaps = false
    @State var pwNeedsNumbers = false
    @State var dataPosted = false
    @State var incorrectCodeAttempted = false
    
    @State var firstDigit = ""
    @State var secondDigit = ""
    @State var thirdDigit = ""
    @State var fourthDigit = ""
    @State var fifthDigit = ""
    @State var sixthDigit = ""
    
    @FocusState var formField:FormFields?
    @FocusState var secField:SecurityCodeFields?
    
    let accent = Color.blue
    var userService:UserNetworking = .shared

    var body: some View {
        VStack {
            if loading {
                ProgressView()
            } else {
                Button(
                    action:{
                        withAnimation {
                            appViewState.currentView = .LoginView
                        }
                    },
                    label: {
                        Text("Cancel")
                            .foregroundColor(accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    })
                Spacer()
                if codeReceived == false {
                    // MARK: Enter Email
                    Group {
                        Text("Forgot Password")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom])
                            .alert(isPresented: $errorOccurred) {
                                Alert(title: Text("Try Again"), dismissButton: .default(Text("OK")))
                            }

                        Text("Enter your email for the verification process, we will send a 6 digit code to your email.")
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom])
                            .alert(isPresented: $invalidEmail) {
                                Alert(title: Text("Please enter a valid email address"))
                            }

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
                        .alert(isPresented: $userNotFound) {
                            Alert(title: Text("Try Again"), message: Text("The email you entered did not match our records. Please double-check and try again."))
                        }

                        Button(
                            action: {
                            withAnimation(.easeIn) {
                                self.loading = true
                            }
                            guard
                                self.email.count > 0,
                                Validators.isValidEmail(email: self.email)
                            else {
                                print("invalid formatted email attempted during forgot password")
                                self.loading = false
                                self.invalidEmail = true
                                return
                            }
                            userService.sendUsernameAndEmailForPasswordRecovery(email: email.trimmingCharacters(in: .whitespacesAndNewlines)) {(secCodeResponse) in
                                switch(secCodeResponse) {
                                case .success( _):
                                    DispatchQueue.main.async {
                                        withAnimation(.easeIn) {
                                            self.loading = false
                                            self.codeReceived = true
                                        }
                                    }
                                case .failure(let err):
                                    DispatchQueue.main.async {
                                        if err == .userNotFound {
                                            userNotFound = true
                                        } else {
                                            errorOccurred = true
                                        }
                                        self.loading = false
                                    }
                                }
                            }
                        },
                            label: {
                                Text("Continue")
                                    .modifier(ContinueButtonStyling())
                            }
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

                        Text("Please check your inbox for the verification code sent to **\(self.email)**. Can't find it? Please check your spam folder.")
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom, .trailing])
                            .alert(isPresented: $codeNotFound) {
                                Alert(title: Text("That code is incorrect"))
                            }

                        HStack {
                            TextField("", text: $firstDigit)
                                .modifier(SecurityCodeTextBox(textCode: $firstDigit, focusedField: _secField, boxNum: .first))
                                .onSubmit {
                                    secField = .second
                                }

                            TextField("", text: $secondDigit)
                                .modifier(SecurityCodeTextBox(textCode: $secondDigit, focusedField: _secField, boxNum: .second))
                                .onSubmit {
                                    secField = .third
                                }

                            TextField("", text: $thirdDigit)
                                .modifier(SecurityCodeTextBox(textCode: $thirdDigit, focusedField: _secField, boxNum: .third))
                                .onSubmit {
                                    secField = .fourth
                                }

                            TextField("", text: $fourthDigit)
                                .modifier(SecurityCodeTextBox(textCode: $fourthDigit, focusedField: _secField, boxNum: .fourth))
                                .onSubmit {
                                    secField = .fifth
                                }

                            TextField("", text: $fifthDigit)
                                .modifier(SecurityCodeTextBox(textCode: $fifthDigit, focusedField: _secField, boxNum: .fifth))
                                .onSubmit {
                                    secField = .sixth
                                }

                            TextField("", text: $sixthDigit)
                                .modifier(SecurityCodeTextBox(textCode: $sixthDigit, focusedField: _secField, boxNum: .sixth))
                        }
                        .multilineTextAlignment(.center)
                        .padding(.bottom)

                        Button(
                            action: {
                                securityCodeFromUser = "\(firstDigit)\(secondDigit)\(thirdDigit)\(fourthDigit)\(fifthDigit)\(sixthDigit)"

                                // check the code
                                checkCode()
                            },
                            label: {
                                Text("Continue")
                                    .modifier(ContinueButtonStyling())
                            }
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
                            .alert(isPresented: $pwNotValid) {
                                Alert(title: Text("Invalid Password"), message: Text("Your password must be at least 8 and no more than 20 characters. It must also contain at least 1 number and 1 capital letter."), dismissButton: .default(Text("OK!")))
                            }

                        Text("Set the new password for your account so you can login.")
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom, .trailing])
                            .alert(isPresented: $pwDontMatch) {
                                Alert(title: Text("Your Passwords Don't Match"))
                            }

                        if showPW == false {
                            HStack(spacing: 0.0) {
                                Image(systemName: "key.fill").foregroundColor(formField == FormFields.password ? accent : Color.gray)
                                SecureField(" Password", text: $password)
                                    .textContentType(UITextContentType.newPassword)
                                    .onChange(of: password) {
                                        password = String($0.prefix(20)) // this limits the char field to 20 chars
                                    }
                                    .textInputAutocapitalization(.never)
                                    .foregroundColor(formField == FormFields.password ? accent : Color.gray)
                                    .disableAutocorrection(true)
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
                                    .textContentType(UITextContentType.newPassword)
                                    .onChange(of: password) {
                                        password = String($0.prefix(20)) // this limits the char field to 16 chars
                                    }
                                    .textInputAutocapitalization(.never)
                                    .foregroundColor(formField == FormFields.passwordPlain ? accent : Color.gray)
                                    .disableAutocorrection(true)
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
                            .padding([.leading, .trailing, .top], 15.0)
                        }

                        if showConfPW == false {
                            HStack(spacing: 0.0) {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textContentType(UITextContentType.newPassword)
                                    .textInputAutocapitalization(.never)
                                    .foregroundColor(formField == FormFields.confirmPassword ? accent : Color.gray)
                                    .disableAutocorrection(true)
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
                            .padding()
                            .alert(isPresented: $pwDontMatch) {
                                Alert(title: Text("Passwords Don't Match"))
                            }
                        } else {
                            HStack(spacing: 0.0) {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .textContentType(UITextContentType.newPassword)
                                    .textInputAutocapitalization(.never)
                                    .foregroundColor(formField == FormFields.confirmPasswordPlain ? accent : Color.gray)
                                    .disableAutocorrection(true)
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
                            .padding()
                            .alert(isPresented: $pwDontMatch) {
                                Alert(title: Text("Passwords Don't Match"))
                            }
                        }

                        if pwNeedsCaps {
                            HStack(spacing: 0.0) {
                                Text("1 Uppercase X").font(.caption2).foregroundColor(.red)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                        }

                        if pwNeedsNumbers {
                            HStack(spacing: 0.0) {
                                Text("1 Number X").font(.caption2).foregroundColor(.red)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                        }

                        Button(
                            action: {
                                guard password == confirmPassword else {
                                    print("passwords dont match")
                                    formField = .password
                                    pwDontMatch = true
                                    return
                                }

                                // check for numbers and cap letters
                                guard Validators.pwContainsUppercase(password: self.password) == true else {
                                    print("pw needs uppercase")
                                    formField = .password
                                    pwNeedsCaps = true
                                    return
                                }

                                guard Validators.pwContainsNumber(password: self.password) == true else {
                                    print("pw needs numbers")
                                    formField = .password
                                    pwNeedsNumbers = true
                                    return
                                }

                                guard
                                    password.count > 8,
                                    password.count < 21
                                else {
                                    print("password length invalid")
                                    formField = .password
                                    pwNotValid = true
                                    return
                                }

                                // kick off the password reset process
                                postNewPassword()
                            },
                            label: {
                                Text("Continue")
                                    .modifier(ContinueButtonStyling())
                                
                            }
                        ).alert(isPresented: $dataPosted) {
                            Alert(title: Text("Success"), message: Text("Your password has been updated. You can go back and log in now."), dismissButton: .default(Text("OK!")) {
                                withAnimation {
                                    appViewState.currentView = .LoginView
                                }
                            })
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    func checkCode() {
        self.loading = true
        userService.checkSecurityCode(email: self.email, securityCode: self.securityCodeFromUser) { serverResponse in
            switch serverResponse {
                case .success(let res):
                    DispatchQueue.main.async {
                        self.loading = false
                        if res == true {
                            withAnimation(.easeInOut) {
                                self.codesMatch = true
                            }
                        } else {
                            self.codesMatch = false
                            self.codeNotFound = true
                            print("wrong code entered")
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print("an error occurred \(err)")
                        self.loading = false
                    }
            }
        }
    }

    func postNewPassword() {
        self.loading = true
        userService.postNewPassword(securityCode: self.securityCodeFromUser, newPassword: self.password) { serverResponse in
            switch serverResponse {
                case .success(let text):
                    DispatchQueue.main.async {
                        self.loading = false
                        if text == "OK" {
                            self.dataPosted = true
                        } else {
                            self.errorOccurred = true
                        }
                    }
                
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.loading = false
                        print(err.localizedDescription)
                        self.errorOccurred = true
                    }
            }
        }
    }
}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword()
    }
}
