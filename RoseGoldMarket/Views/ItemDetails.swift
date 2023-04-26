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
    @State var showMessageBubble = false
    @State var messageForOwner = ""
    @State var inquirySent = false
    @FocusState var sendingMessage:Bool
    @EnvironmentObject var messenger:MessagingViewModel
    @EnvironmentObject var user:UserModel
    @EnvironmentObject var context:PopToRoot // detect when usr hits home tab btn
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geo in
            VStack (alignment: .center, spacing: 15) {
                if sendingMessage == false {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/\(item.itemImageFolderPath)/image1.jpg")) { imagePhase in
                                if let image = imagePhase.image {
                                    image.resizable().scaledToFill().frame(width: determinePhotoDimensions(viewHeight: geo.size.height), height: determinePhotoDimensions(viewHeight: geo.size.height)).cornerRadius(25).shadow(radius: 5)
                                } else if imagePhase.error != nil {
                                    Text("Problem loading image")
                                } else {
                                    ProgressView()
                                }
                            }

                            AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/\(item.itemImageFolderPath)/image2.jpg")) { imagePhase in
                                if let image = imagePhase.image {
                                    image.resizable().scaledToFill().frame(width: determinePhotoDimensions(viewHeight: geo.size.height), height: determinePhotoDimensions(viewHeight: geo.size.height)).cornerRadius(25).shadow(radius: 5)
                                } else if imagePhase.error != nil {
                                    Text("Problem loading image")
                                } else {
                                    ProgressView()
                                }
                            }

                            AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/\(item.itemImageFolderPath)/image3.jpg")) { imagePhase in
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
                
                }
                //ScrollView {
                    Text(item.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color("MainColor"))
                    
                HStack {
                    Text("Date Posted: \(self.formatDate(date: item.dateposted))").font(.footnote).fontWeight(.medium).foregroundColor(Color("AccentColor"))
                    Spacer()
                    if item.ownerUsername != nil {
                        Text("Owner: \(item.ownerUsername!)").font(.footnote).fontWeight(.medium).foregroundColor(Color("AccentColor"))
                    }
                }
                    //.frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text(item.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                    
                
                    Text("Send owner a message").fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        TextField("", text: $messageForOwner, axis: .vertical)
                            .focused($sendingMessage, equals: true)
                            .onChange(of: messageForOwner) {
                                // limit the inquiry to 100 characters
                                messageForOwner = String($0.prefix(100))
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button("Done") {
                                        withAnimation {
                                            sendingMessage = false
                                        }
                                        
                                        
                                    }.foregroundColor(.blue)
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color(.systemGray6)))
                        Button(
                            action: {
                                // send the message to the owner
                                let _ = messenger.sendMessageToUserV2(newMessage: messageForOwner, receiverId: item.owner, receiverUsername: item.ownerUsername ?? "", senderUsername: user.username, senderId: user.accountId)
                                self.inquirySent.toggle()
                            },
                            label: {
                                Text("Send")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(height: 50)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue))
                            }
                        ).onAppear() {
                            self.messageForOwner = "Hello, is \(self.item.name) still available?"
                        }
                    }.alert(isPresented: $inquirySent) {
                        Alert(title: Text("Your message was sent"))
                    }
                //}
                Spacer()
            }
            .padding([.leading, .trailing])
        }.onChange(of: context.navToHome) { _ in
            // when this value is changed, get the user out of the detail view
            dismiss()
        }
    }
    
    func determinePhotoDimensions(viewHeight: CGFloat) -> CGFloat {
        if viewHeight < 600 {
            return 200
        } else {
            return 250
        }
    }
}

extension ItemDetails {
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct ItemDetails_Previews: PreviewProvider {
    static let messenger = MessagingViewModel.shared
    static let previewUser = UserModel.shared
    static let imageLink = "/Users/asimbrown/Desktop/Dev/Projects/RoseGold/build/images/braxton97/Oak Tree/image1.jpg"
    static let imageLink2 = "/Users/asimbrown/Desktop/Dev/Projects/RoseGold/build/images/braxton97/Oak Tree/image2.jpg"
    static let imageLink3 = "/Users/asimbrown/Desktop/Dev/Projects/RoseGold/build/images/braxton97/Oak Tree/image3.jpg"
    static let context = PopToRoot()
    static let item = Item(id: 5, name: "Weed", description: "weed for you and me", owner: 6, isavailable: true, pickedup: false, dateposted: Date(), categories: ["indoor", "tropical"], image1: imageLink, image2: imageLink2, image3: imageLink3, ownerUsername: nil)
    
    static var previews: some View {
        ItemDetails(item: item, viewingFromAccountDetails: false)
            .environmentObject(messenger)
            .environmentObject(previewUser)
            .environmentObject(context)
    }
}
