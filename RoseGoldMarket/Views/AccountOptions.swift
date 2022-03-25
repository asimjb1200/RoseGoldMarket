//
//  AccountOptions.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI

struct AccountOptions: View {
    @EnvironmentObject var user:UserModel
    @State var confirmLogout = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: ChangeLocation(), label: {Text("Change Your Location")})

                    NavigationLink(destination: FavoriteItems(), label: {Text("Favorite Items")})

                    NavigationLink(destination: MyListings(), label: {Text("My Listings")})

                    NavigationLink(destination: EmailSupport(), label: {Text("Email Support")})
                    
                    Button("Log Out") {
                        confirmLogout.toggle()
                    }
                    .alert(isPresented: $confirmLogout){
                        Alert(title: Text("Are You Sure?"), primaryButton: .default(Text("Yes"), action: {
                            user.logout()
                        }),
                              secondaryButton: .cancel())
                    }
                }
            }
        }.navigationBarHidden(true)
    }
}

struct AccountOptions_Previews: PreviewProvider {
    static var previews: some View {
        AccountOptions()
            .environmentObject(UserModel.shared)
    }
}
