//
//  AccountOptions.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI

struct AccountOptions: View {
    let accountOptions = ["Change Location", "Favorites", "My Listings", "Email Support"]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: ChangeLocation(), label: {Text("Change Your Location")})

                    NavigationLink(destination: FavoriteItems(), label: {Text("Favorite Items")})

                    NavigationLink(destination: MyListings(), label: {Text("My Listings")})

                    NavigationLink(destination: EmailSupport(), label: {Text("Email Support")})
                }
            }
        }.navigationBarHidden(true)
    }
}

struct AccountOptions_Previews: PreviewProvider {
    static var previews: some View {
        AccountOptions()
    }
}
