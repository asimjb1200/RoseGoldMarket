//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
struct ContentView: View {
    @State var tab: Int = 0
    @State var firstAppear = true
    @StateObject var messenger: MessagingViewModel = .shared
    @EnvironmentObject var user:UserModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    var profanityChecker:InputChecker = .shared
    let socket:SocketUtils = .shared
    
    init() {
        let appearance = UITabBar.appearance()
        appearance.backgroundColor = colorScheme == .light ? UIColor(Color.white.opacity(0.5)) : UIColor(Color.gray)
    }
    
    var body: some View {
        TabView(selection: $tab) {
            HomeMarket(tab: $tab)
                .tabItem {
                    Label("Market", systemImage: "house.fill")
                }.tag(0)

            AddItems(tab: $tab)
                .tabItem {
                    Label("Add Item", systemImage: "plus.circle")
                }.tag(1)

            MessageList(tab: $tab)
                .tabItem {
                    Label("Messages", systemImage: "envelope.fill")
                }
                .tag(2)
                .badge(messenger.newMsgCount)

            AccountOptions()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }.tag(3)

        }.accentColor(Color("AccentColor"))
        .onAppear() {
            if firstAppear {
                messenger.getAllMessages(user: user)
                firstAppear = false
            }
        }
        .environmentObject(messenger)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if !firstAppear && user.accountId != 0 {
                    socket.connectToServer(withId: user.accountId)
                    messenger.getAllMessages(user: user)
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                socket.disconnectFromServer(accountId: user.accountId)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
