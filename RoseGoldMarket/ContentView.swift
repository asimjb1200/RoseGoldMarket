//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
import Combine
import AppTrackingTransparency
import FBSDKCoreKit
import os

struct ContentView: View {
    @StateObject var context = PopToRoot()
    @State var tab: Int = 0
    @State var firstAppear = true
    @StateObject var messenger: MessagingViewModel = .shared
    // @EnvironmentObject private var subHandler: SubscriptionHandler
    @EnvironmentObject var user:UserModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    let userService:UserNetworking = .shared
    let socket:SocketUtils = .shared

    var body: some View {
        TabView(selection: $context.selectedTab) {
            HomeMarket(tab: $context.selectedTab)
                .environmentObject(context)
                .tabItem {
                    Label("Market", systemImage: "house.fill")
                }.tag(0)

            AddItems(tab: $context.selectedTab)
                .tabItem {
                    Label("Add Item", systemImage: "plus.circle")
                }.tag(1)

            MessageList(tab: $context.selectedTab)
                .edgesIgnoringSafeArea(.top)
                .tabItem {
                    Label("Messages", systemImage: "envelope.fill")
                }
                .tag(2)
                .badge(messenger.newMsgCount)

            AccountOptions()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }.tag(3)
        }
        .onReceive(context.$selectedTab) {
            if $0 == 0 {
                context.navToHome.toggle()
            }
        }
        .accentColor(Color("AccentColor"))
        .onAppear() {
            if firstAppear {
                Task {
                    async let latestMessagesCall: () = messenger.getLatestMessages(viewingUser: user.accountId, user: user)
                    async let unreadMessagesCall: () = messenger.getUnreadMessagesForUser(user: user)
                    await [latestMessagesCall, unreadMessagesCall]
                    firstAppear = false
                }
            }
            
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//                if let error = error {
//                    print("D'oh: \(error.localizedDescription)")
//                } else {
//                    DispatchQueue.main.async {
//                        UIApplication.shared.registerForRemoteNotifications()
//                    }
//                }
//            }
            
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                    case .authorized:
                        FBSDKCoreKit.Settings.shared.isAdvertiserTrackingEnabled = true
                        FBSDKCoreKit.Settings.shared.isAutoLogAppEventsEnabled = true
                        FBSDKCoreKit.Settings.shared.isAdvertiserIDCollectionEnabled = true
                    case .denied:
                        FBSDKCoreKit.Settings.shared.isAdvertiserTrackingEnabled = false
                        FBSDKCoreKit.Settings.shared.isAutoLogAppEventsEnabled = false
                        FBSDKCoreKit.Settings.shared.isAdvertiserIDCollectionEnabled = false
                    default:
                        FBSDKCoreKit.Settings.shared.isAdvertiserTrackingEnabled = false
                        FBSDKCoreKit.Settings.shared.isAutoLogAppEventsEnabled = false
                        FBSDKCoreKit.Settings.shared.isAdvertiserIDCollectionEnabled = false
                }
            }
        }
        .environmentObject(messenger)
        .environmentObject(context)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { // for when the user comes back to the app
                if !firstAppear && user.accountId != 0 {
                    socket.connectToServer(withId: user.accountId)
                    Task {
                        async let latestMessages: () = messenger.getLatestMessages(viewingUser: user.accountId, user: user)
                        async let unreadMessages: () = messenger.getUnreadMessagesForUser(user: user)
//
                        await [latestMessages, unreadMessages]
                    }
                }
                print("active")
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("background")
                socket.disconnectFromServer(accountId: user.accountId)
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: .deviceTokenReceived)) { newTokenObject in
//            if let deviceIdentifier = newTokenObject.object as? String {
//                os_log(.debug, "Device Token received")
//
//                Task {
//                    do {
//                        _ = try await userService.sendDeviceTokenToServer(deviceToken: deviceIdentifier, accessToken: user.accessToken)
//                    } catch let err {
//                        print(err)
//                    }
//                }
//            } else {
//                print("couldn't get it")
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserModel.shared)
    }
}
