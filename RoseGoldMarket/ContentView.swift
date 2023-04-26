//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

class PopToRoot: ObservableObject {
    @Published var navToHome = false
    @Published var selectedTab: Int = 0
}

struct ContentView: View {
    @StateObject var context = PopToRoot()
    @State var tab: Int = 0
    @State var firstAppear = true
    @StateObject var messenger: MessagingViewModel = .shared
    @EnvironmentObject var user:UserModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    let socket:SocketUtils = .shared

    var body: some View {
        TabView(selection: $context.selectedTab) {
            HomeMarket(tab: $context.selectedTab).environmentObject(context)
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
                messenger.getLatestMessages(viewingUser: user.accountId, user: user)
                messenger.getUnreadMessagesForUser(user: user)
                firstAppear = false
            }
        }
        .environmentObject(messenger)
        .environmentObject(context)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { // for when the user comes back to the app
                if !firstAppear && user.accountId != 0 {
                    socket.connectToServer(withId: user.accountId)
                    messenger.getLatestMessages(viewingUser: user.accountId, user: user)
                    messenger.getUnreadMessagesForUser(user: user)
                }
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("background")
                socket.disconnectFromServer(accountId: user.accountId)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserModel.shared)
    }
}
