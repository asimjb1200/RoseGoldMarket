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
    @EnvironmentObject var context:PopToRoot // detect when usr hits home tab btn
    @Environment(\.presentationMode) private var presentation
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        
                        AsyncImage(url: URL(string: "https://rosegoldgardens.com/api\(self.getImageLink(imageLink: item.image1))")) { imagePhase in
                            if let image = imagePhase.image {
                                image.resizable().scaledToFill().frame(width: determinePhotoDimensions(viewHeight: geo.size.height), height: determinePhotoDimensions(viewHeight: geo.size.height)).cornerRadius(25).shadow(radius: 5)
                            } else if imagePhase.error != nil {
                                Text("Problem loading image")
                            } else {
                                ProgressView()
                            }
                        }

                        AsyncImage(url: URL(string: "https://rosegoldgardens.com/api\(self.getImageLink(imageLink: item.image2))")) { imagePhase in
                            if let image = imagePhase.image {
                                image.resizable().scaledToFill().frame(width: determinePhotoDimensions(viewHeight: geo.size.height), height: determinePhotoDimensions(viewHeight: geo.size.height)).cornerRadius(25).shadow(radius: 5)
                            } else if imagePhase.error != nil {
                                Text("Problem loading image")
                            } else {
                                ProgressView()
                            }
                        }

                        AsyncImage(url: URL(string: "https://rosegoldgardens.com/api\(self.getImageLink(imageLink: item.image3))")) { imagePhase in
                            if let image = imagePhase.image {
                                image.resizable().scaledToFill().frame(width: determinePhotoDimensions(viewHeight: geo.size.height), height: determinePhotoDimensions(viewHeight: geo.size.height)).cornerRadius(25).shadow(radius: 5)
                            } else if imagePhase.error != nil {
                                Text("Problem loading image")
                            } else {
                                ProgressView()
                            }
                        }
                    }.frame(height: determinePhotoDimensions(viewHeight: geo.size.height))
                    
                }.alert(isPresented: $inquirySent) {
                    Alert(title: Text("Your Inquiry Was Sent"), message: Text("Give the owner some time to get back to you."), dismissButton: .default(Text("OK!"), action: {inquirySent = true}))
                }
                
                Text("Date Posted: \(self.formatDate(date: item.dateposted))").font(.footnote).fontWeight(.medium).foregroundColor(Color("AccentColor")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("MainColor"))
                
                ScrollView {
                    Text(item.description)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25.0).fill(Color.gray.opacity(0.5)))
                        .padding([.leading, .trailing])
                    
                    
                    if viewingFromAccountDetails == false && inquirySent == false && item.owner != user.accountId {
                        Button("Contact Owner About Plant") {
                            // if not coming from the account details view, then I know that the product's owner will be inside item object
                            let newMessage = "Hello, I am contacting you about the plant you own named \(item.name). I wanted to know if it is still available?"
                            
                            if let itemOwnersUsername = item.ownerUsername {
                                _ = messenger.sendMessageToUser(newMessage: newMessage, receiverId: item.owner, receiverUsername: itemOwnersUsername, senderUsername: user.username, senderId: user.accountId)
                                inquirySent = true
                            }
                        }
                        .padding()
                       
                    }
                }
                Spacer()
            }
        }.onChange(of: context.navToHome) { _ in
            // when this value is changed, get the user out of the detail view
            presentation.wrappedValue.dismiss()
        }
    }
    
    func determinePhotoDimensions(viewHeight: CGFloat) -> CGFloat {
        if viewHeight < 600 {
            return 250
        } else {
            return 350
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
