//
//  HomeMarket.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

struct HomeMarket: View {
    var body: some View {
        NavigationView {
            Text("Home View")
                .navigationBarTitle("Marketplace")
        }
    }
}

struct HomeMarket_Previews: PreviewProvider {
    static var previews: some View {
        HomeMarket()
    }
}
