//
//  ContentView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeMarket()
                .tabItem {
                    Label("Market", systemImage: "house.fill")
                }.tag(0)
            
            AddItems()
                .tabItem {
                    Label("Add Item", systemImage: "plus.circle")
                }.tag(1)
            
        }.accentColor(Color("AccentColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
