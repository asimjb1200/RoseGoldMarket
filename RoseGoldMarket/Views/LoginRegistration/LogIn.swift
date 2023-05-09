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
    @State var password = ""
    @State var email = ""
    @State var isLoading = false
    @State var verificationCodeError = false
    @EnvironmentObject var globalUser:UserModel
    @EnvironmentObject var appViewState: CurrentAppView
    @EnvironmentObject private var subHandler: SubscriptionHandler
    var appBanner:UIImage? = UIImage(named: "UpdatedBanner")
    var service:UserNetworking = .shared
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
            
            if subHandler.subPurchaseLoading {
                ProgressView()
            } else {
                if !subHandler.firstMonthOver() {
                    LoginTextBoxes(email: $email, password: $password).environmentObject(globalUser).environmentObject(appViewState)
                } else {
                    if !subHandler.isSubscribed {
                        Text("Please sign up for one of our automatic subscription options to continue seamlessly.").frame(maxWidth: .infinity, alignment: .center).padding()
                        Menu {
                            ForEach(subHandler.products) {(product) in
                                Button {
                                    Task {
                                        do {
                                            try await subHandler.purchase(product)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    Text("\(product.displayPrice) - \(product.displayName)")
                                }
                            }
                        } label: {
                            Text("Subscription Options")
                                .fontWeight(.bold)
                                .frame(width: buttonWidth)
                                .foregroundColor(.white)
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth, height: 50))
                                .padding()
                        }
                        Spacer()
                    } else {
                        LoginTextBoxes(email: $email, password: $password).environmentObject(globalUser).environmentObject(appViewState)
                    }
                }
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
                }
                .padding(.top, 15)
                .alert(isPresented: $verificationCodeError) {
                    Alert(title: Text("There was a problem"), message: Text("Try again or contact us."))
                }
            }.offset(y: 40)
            Spacer()
            Button(
                action: {appViewState.currentView = .RegistrationView},
                label: {
                    Text("Don't have an account? \(Text("Sign Up").foregroundColor(.blue))").padding(.bottom)
                }
            )
        }
        .onOpenURL { url in
            print("URL OPENED. let's give them a loading screen while we verify the code: \(url)")
            // this is going to open for every link the login page receives, so I'll have to do some addtl checks
            self.isLoading = true
            
            if let urlComponents = URLComponents(string: url.absoluteString) {
                let queryItems = urlComponents.queryItems
                guard let userInfoHash = queryItems?.first(where: {$0.name == "userInformation"})?.value else {
                    print("not from our server")
                    self.isLoading = false
                    return
                }
                guard let userEmail = queryItems?.first(where: {$0.name == "emailAddress"})?.value else {
                    self.isLoading = false
                    return
                }
                
                // now build a request and post this data back to the server to see if the codes are correct
                service.verifyAccount(userEmailAddress: userEmail, userInformationHash: userInfoHash, completion: { verificationResponse in
                    switch(verificationResponse) {
                    case .success( _):
                        DispatchQueue.main.async {
                            print("they can login now")
                            self.isLoading = false
                        }
                    case .failure(let verificationError):
                        print(verificationError)
                        if verificationError == .wrongCode {
                            print("the code they attempted was invalid")
                        } else if verificationError == .userNotFound {
                            print("that user couldn't be found")
                        } else {
                            print("a server side error occurred")
                        }
                        self.isLoading = false
                        self.verificationCodeError = true
                    }
                })
            } else {
                print("one of the social media share links was clicked")
                self.isLoading = false
            }
        }
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn().environmentObject(UserModel.shared).environmentObject(SubscriptionHandler()).environmentObject(CurrentAppView())
    }
}
