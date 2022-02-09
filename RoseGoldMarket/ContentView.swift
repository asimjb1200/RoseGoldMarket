//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
struct ContentView: View {
    @State var tab: UInt = 0
    init() {
//        UITabBar.appearance().isTranslucent = false
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
                }.tag(2)
        }
        .accentColor(Color("AccentColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
