//
//  AccountDetailsView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/24/22.
//

import SwiftUI

struct AccountDetailsView: View {
    @State var errorOccurred = false
    @State var reportingUser = false
    @State var reason = ""
    @State var reportSent = false
    @State var reportError = false
    @State var noReasonProvided = false
    @State var sendingMessage = false
    
    var buttonWidth = UIScreen.main.bounds.width * 0.85
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

                Button(
                    action: {
                        self.reportingUser.toggle()
                    },
                    label: {
                        Text("Report User?")
                            .font(.title3)
                            .padding([.bottom, .top])
                    }
                )
                
                
                Text("Current Listings").font(.title3).fontWeight(.bold).padding([.top, .bottom])
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
            }.sheet(isPresented: $reportingUser) {
                VStack {
                    if sendingMessage {
                        ProgressView()
                    } else {
                        Text("What Happened").font(.title).fontWeight(.heavy).padding([.top, .bottom])
                            .alert(isPresented: $reportError) {
                                Alert(title: Text("There Was A Problem"), message: Text("Your concern is important to us. Please try again later."))
                            }
                        
                        Divider().padding([.leading, .trailing])
                            .alert(isPresented: $noReasonProvided) {
                                Alert(title: Text("Please Provide A Reason"))
                            }
                        //Spacer()
                        TextField("200 Characters Max", text: $reason, axis: .vertical)
                            .padding()
                            .onChange(of: reason) {
                                reason = String($0.prefix(200))
                            }
                            .alert(isPresented: $reportSent) {
                                Alert(title: Text("Report Sent"), message: Text("We'll look into this situation and take the necessary steps to ensure our users safety."))
                            }
                        Spacer().frame(height: 100)
                        Button(
                            action: {
                                guard !reason.isEmpty else {
                                    noReasonProvided.toggle()
                                    return
                                }

                                sendReportMessage()
                            },
                            label: {
                                Text("Submit")
                                    .foregroundColor(Color.white)
                                    .frame(width: buttonWidth)
                                    .font(.system(size: 16, weight: Font.Weight.bold))
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth))
                                    .padding(.top)
                            }
                        )
                        Spacer()
                    }
                }
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
    
    func sendReportMessage() {
        sendingMessage = true
        UserNetworking.shared.reportAUser(userToReport: accountid, reportingUser: user.accountId, reason: reason, token: user.accessToken) { reportResponse in
            switch reportResponse {
                case .success(let reportSentRes):
                    DispatchQueue.main.async {
                        sendingMessage = false
                        if reportSentRes {
                            reason = ""
                            reportSent = true
                        } else {
                            reportError = true
                        }
                    }

                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                        sendingMessage = false
                        self.errorOccurred = true
                    }
            }
        }
    }
}

struct AccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailsView(username: "dee", accountid: 15).environmentObject(UserModel.shared)
    }
}
