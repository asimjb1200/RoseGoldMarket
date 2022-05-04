//
//  AccountDetailsView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/24/22.
//

import SwiftUI

struct AccountDetailsView: View {
    @State var errorOccurred = false
    let username:String
    let accountid:UInt
    let service = ItemService()
    let columns = [ // I want two columns of equal width on this view
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    @State var items: [Item] = []
    @EnvironmentObject var user:UserModel
    
    var body: some View {
            VStack {
                AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/avatars/\(username).jpg")) { phase in
                    if let image = phase.image {
                        image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(maxWidth: 200, maxHeight: 200)
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        ProgressView()
                            .foregroundColor(Color("MainColor"))
                            .frame(width: 100, height: 100)
                    }
                }
                
                Text(username)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .alert(isPresented: $errorOccurred) {
                        Alert(title: Text("There was a problem."), message: Text("Your items could not be retrieved at this time. Come back later."))
                    }
                
                
                Text("Their Items")
                ScrollView {
                    if self.items.isEmpty {
                        Text("No Items Available").font(.largeTitle)
                    } else {
                        LazyVGrid (columns: columns) {
                            ForEach(self.items, id: \.id) { x in
                                NavigationLink(destination: ItemDetails(item: x, viewingFromAccountDetails: true)) {
                                    ItemPreview(itemId: x.id, itemTitle: x.name, itemImageLink: x.image1)
                                }
                            }
                        }
                    }
                }.frame(height: 300)
                Spacer()
                
            }.onAppear() {
                self.fetchUserItems()
            }
    }
}

extension AccountDetailsView {
    func fetchUserItems() {
        service.retrieveItemsForAccount(accountId: accountid, token: user.accessToken, completion: { dataRes in
            switch dataRes {
            case .success(let itemData):
                DispatchQueue.main.async {
                    self.items = itemData.data
                    if itemData.newToken != nil {
                        user.accessToken = itemData.newToken!
                    }
                }
                
            case .failure(let error):
                self.errorOccurred = true
                if error == .tokenExpired {
                    self.user.logout()
                }
                print(error.localizedDescription)
            }
        })
    }
}

struct AccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailsView(username: "dee", accountid: 17)
    }
}
