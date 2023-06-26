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
    @State var appViewState: AppViewStates = .LandingPage
    var service:UserNetworking = .shared
    @StateObject var user:UserModel = .shared
    @StateObject var currentAppView:CurrentAppView = CurrentAppView()
    // @StateObject var subHandler = SubscriptionHandler()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if self.isLoading {
                ProgressView().tint(Color.blue)
            } else {
                if user.isLoggedIn {
                    ContentView()
                        .environmentObject(user)
                } else {
                    switch currentAppView.currentView {
                        case .LandingPage:
                            LandingPage()
                            .environmentObject(currentAppView)
                            //.environmentObject(subHandler)
                            
                        case .LoginView:
                            LogIn()
                                .environmentObject(user)
                                .environmentObject(currentAppView)
                                //.environmentObject(subHandler)
                            
                        case .RegistrationView:
                            Register()
                                .environmentObject(user)
                                .environmentObject(currentAppView)
                        
                    case .ForgotPassword:
                        ForgotPassword().environmentObject(currentAppView)
                    }
                }
            }
        }
    }
}
