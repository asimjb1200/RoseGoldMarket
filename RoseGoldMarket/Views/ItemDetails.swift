//
//  ItemDetails.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/29/22.
//

import SwiftUI

struct ItemDetails: View {
    let item: Item
    let viewingFromAccountDetails: Bool
    @State var inquirySent = false
    @EnvironmentObject var messenger:MessagingViewModel
    @EnvironmentObject var user:UserModel
    
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image1))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }

                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image2))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }

                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image3))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }
                }.frame(height: 200)
                
            }.alert(isPresented: $inquirySent) {
                Alert(title: Text("Your Inquiry Was Sent"), message: Text("Give the owner some time to get back to you."), dismissButton: .default(Text("OK!"), action: {inquirySent = true}))
            }
            
            Text("Date Posted: \(self.formatDate(date: item.dateposted))").font(.footnote).fontWeight(.medium).foregroundColor(Color("AccentColor")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
            Text(item.name)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(Color("MainColor"))
                .padding()
            
            Text(item.description).frame(height: 100).padding()
            
            
            if viewingFromAccountDetails == false && inquirySent == false && item.owner != user.accountId{
                Button("Contact Owner About Plant") {
                    // if not coming from the account details view, then I know that the product's owner will be inside item object
                    let newMessage = "Hello, I am contacting you about the plant you own named \(item.name). I wanted to know if it is still available?"
                    
                    if let itemOwnersUsername = item.ownerUsername {
                        _ = messenger.sendMessageToUser(newMessage: newMessage, receiverId: item.owner, receiverUsername: itemOwnersUsername, senderUsername: user.username, senderId: user.accountId)
                        inquirySent = true
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}

extension ItemDetails {
    func getImageLink(imageLink: String) -> String {
        // chop up the image url
        let linkArray = imageLink.components(separatedBy: "/build")
        
        return linkArray[1].replacingOccurrences(of: " ", with: "%20")
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct ItemDetails_Previews: PreviewProvider {
    static var previews: some View {
        let item = Item(id: 5, name: "Weed", description: "weed for you and me", owner: 6, isavailable: true, pickedup: false, dateposted: Date(), categories: ["indoor", "tropical"], image1: "/image1.jpg", image2: "/image2.jpg", image3: "/image3.jpg", ownerUsername: nil)
        ItemDetails(item: item, viewingFromAccountDetails: false)
    }
}
