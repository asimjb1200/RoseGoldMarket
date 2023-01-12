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
    @Binding var appViewState: AppViewStates
    var appBanner:UIImage? = UIImage(named: "UpdatedBanner")
    var service:UserNetworking = .shared
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    let accent = Color.blue
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if appBanner != nil {
                    Image(uiImage: appBanner!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.bottom)
                    
                } else {
                    Text("Rose Gold Gardens")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("MainColor"))
                }
                
                Group {
                    Text("Welcome Back!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        
                    Text("Log in to your Rose Gold Markets account")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .offset(y: 10)
                        .padding(.bottom)
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
                .alert(isPresented: $badPw) {
                    Alert(title: Text("Incorrect Password"), message: Text("Your password contains invalid characters"), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: ForgotPassword()) {
                    Text("Forgot Password?").font(.subheadline).frame(maxWidth: .infinity, alignment: .trailing).foregroundColor(.blue)
                }
                
                if loading {
                    ProgressView()
                } else {
                    Button("Log In") {
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
                }
                
                Group {
                    Text("Share Us!").font(.footnote).foregroundColor(Color.gray).padding(.top)
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
                    }.padding(.bottom)
                }.padding(.bottom)

                Spacer()
                NavigationLink(destination: Register(appViewState: $appViewState)) {
                    Text("Don't have an account? \(Text("Sign Up").foregroundColor(.blue))")
                }
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .padding()
        }
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
        LogIn(appViewState: Binding.constant(.LoginView))
    }
}
