//
//  LogIn.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import LocalAuthentication
import FacebookShare
import Social

struct LogIn: View {
    // @State var username = ""
    @State var password = ""
    @State var email = ""
    @State var badPw = false
    @State var badUsername = false
    @State var badEmail = false
    @State var badCreds = false
    @State var loading = false
    @FocusState private var focusedField:FormFields?
    @EnvironmentObject var globalUser:UserModel
    @EnvironmentObject var appViewState: CurrentAppView
    var appBanner:UIImage? = UIImage(named: "UpdatedBanner")
    var service:UserNetworking = .shared
    let accent = Color.blue
    //let darkGreen = Color("DarkGreen") may try to do a gradient type thing under the banner in the future
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    
    var body: some View {
        VStack(spacing: 0) {
            if appBanner != nil {
                    Image(uiImage: appBanner!)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)

            } else {
                Text("Rose Gold Gardens")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("MainColor"))
            }
            Spacer()
            Group {
                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Log in to your Rose Gold Gardens account")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 25)
            }
            
            
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
            
            Group {
                Text("Share Us!").font(.footnote).foregroundColor(Color.gray)
                HStack {
                    Image("Instagram")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding([.leading, .trailing], 30)
                        .onTapGesture {
                            let text = "instagram://sharesheet?text=For endless floral discoveries, check out the Rose Gold Garden marketplace on the Apple Store: https://google.com"
                            guard
                                let urlQuery = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                                let url = URL(string: urlQuery)
                            else {
                                print("couldnt encode query and build url")
                                return
                            }
                            
                            // check for the instagram app
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                print("App not installed")
                            }
                        }
                    
                    Image("TwitterLogo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding([.leading, .trailing], 30)
                        .onTapGesture {
                            let tweetText = "For endless floral discoveries, check out the Rose Gold Garden marketplace on the Apple Store: "
                            let urlForTweet = "www.rosegoldgardens.com"
                            let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(urlForTweet)"
                            
                            // encode a space to %20 for example
                            guard let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                                print("couldnt encode url")
                                return
                            }
                            
                            // cast to an url
                            guard let url = URL(string: escapedShareString) else {
                                print("couldnt build url for twitter")
                                return
                            }
                            
                            // open in safari
                            UIApplication.shared.open(url)
                        }
                    
                    Image("Facebook")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding([.leading, .trailing], 30)
                        .onTapGesture {
                            // update this with my app's app store link
                            guard let url = URL(string: "https://developers.facebook.com") else {
                                return
                            }
                            
                            // Developer Policies, including section 2.3 which states that apps may not pre-fill in the context of the share sheet. This means apps may not pre-fill the share sheet's initialText field with content that wasn't entered by the user of the app.
                            let content = ShareLinkContent()
                            content.contentURL = url
                            content.hashtag = Hashtag("#RoseGoldGardens")
                            
                            
                            let dialog = ShareDialog(
                                viewController: UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController,
                                content: content,
                                delegate: nil
                            )
                            //dialog.mode = .shareSheet
                            dialog.show()
                        }
                }.padding(.top, 15)
            }.offset(y: 40)
            Spacer()
            Button(
                action: {appViewState.currentView = .RegistrationView},
                label: {
                    Text("Don't have an account? \(Text("Sign Up").foregroundColor(.blue))").padding(.bottom)
                }
            )
            
            //
            
        }
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
    
    func loginWithEmail() {
        self.loading = true
        service.loginWithEmail(email: email.lowercased().filter { !$0.isWhitespace }, pw: password.filter{ !$0.isWhitespace }) { userData in
            switch (userData) {
                case .success(let userRes):
                    DispatchQueue.main.async {
                        service.saveUserToDevice(user: userRes.data)
                        service.saveAccessToken(accessToken: userRes.data.accessToken)
                        let savedPassword = service.loadUserPassword()

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
