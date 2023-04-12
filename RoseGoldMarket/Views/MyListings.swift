//
//  MyListings.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//
import SwiftUI

struct MyListings: View {
    @State var myItems:[ItemNameAndId] = []
    @EnvironmentObject var user:UserModel
    var body: some View {
        VStack {
            if myItems.isEmpty {
                Text("You Don't Have Any Items Right Now")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AccentColor"))
            } else {
                List(myItems, id: \.self) { x in
                    NavigationLink(destination: EditItem(itemName: x.name, ownerName: user.username, itemId: x.id)) {
                        Text(x.name)
                    }
                }
            }
        }
        .navigationBarTitle(Text("My Current Listings"), displayMode: .inline)
        .onAppear {
            self.getUsersItems()
        }
    }
    
    func getUsersItems() {
        UserNetworking.shared.fetchUsersItems(accountId: user.accountId, token: user.accessToken, completion: { itemResponse in
            switch itemResponse {
                case .success(let itemData):
                    DispatchQueue.main.async {
                        if itemData.newToken != nil {
                            user.accessToken = itemData.newToken!
                        }
                        if !itemData.data.isEmpty {
                            myItems = itemData.data
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
            }
        })
    }
}

struct MyListings_Previews: PreviewProvider {
    static var previews: some View {
        MyListings()
    }
}
