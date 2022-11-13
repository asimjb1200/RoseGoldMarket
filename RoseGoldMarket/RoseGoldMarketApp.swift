//
//  RoseGoldMarketApp.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
import FacebookCore

@main
struct RoseGoldMarketApp: App {
    @State var firstAppear = true
    @State var isLoading = false
    @State var verificationCodeError = false
    var service:UserNetworking = .shared
    @StateObject var user:UserModel = .shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            if user.isLoggedIn {
                ContentView()
                    .environmentObject(user)
            } else {
                if self.isLoading {
                    ProgressView().tint(Color.blue)
                } else {
                    LogIn()
                        .alert(isPresented: $verificationCodeError) {
                            Alert(title: Text("There was a problem"), message: Text("Try again or contact us."))
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
                        .environmentObject(user)
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

extension RoseGoldMarketApp {
    func startUpStuff() {
        // check for a user in user defaults storage
        let storedUser:ServiceUser? = UserNetworking.shared.loadUserFromDevice()
        if storedUser != nil {
            user.username = storedUser!.username
            user.accountId = storedUser!.accountId
            user.avatarUrl = storedUser!.avatarUrl
            
            // now search for the user's access token from the keychain
            let storedAccessToken = UserNetworking.shared.loadAccessToken()
            guard let storedAccessToken = storedAccessToken else {
                return
            }
            user.accessToken = storedAccessToken

            user.isLoggedIn = true
            self.isLoading = false
        } else {
            // user.isLoggedIn = false
            self.isLoading = false
        }
    }
}
