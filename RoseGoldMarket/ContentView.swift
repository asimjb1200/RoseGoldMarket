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
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.white) 
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
