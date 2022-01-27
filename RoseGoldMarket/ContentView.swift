//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
struct ContentView: View {
    @State var tab: Int = 0
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
        }
        .accentColor(Color("AccentColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
