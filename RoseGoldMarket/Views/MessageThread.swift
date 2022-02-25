//
//  MessageThread.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageThread: View {
    @State var newMessage = ""
    @EnvironmentObject var viewModel: MessagingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // @EnvironmentObject var user:UserModel
    
    var myUsername = "admin"
    var myAccountId:UInt = 16
    var receiverId:UInt
    
    var body: some View {
        VStack{
            HStack {
            Image(systemName: "arrow.backward")
                .foregroundColor(Color("AccentColor"))
                .frame(maxWidth:.infinity, alignment: .leading)
                .padding()
                .onTapGesture {
                    print("back arrow tapped")
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Text(
                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername == myUsername ?
                    viewModel.allChats[String(receiverId)]!.first!.senderUsername :
                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername
                )
                .fontWeight(.bold)
                .foregroundColor(Color("MainColor"))
                .padding()
                .onTapGesture {
                    print("take them to the Profile")
                }
            }
            ScrollViewReader { scroller in
                VStack {
                        ScrollView {
                            ForEach(viewModel.allChats[String(receiverId)]!, id: \.id) { x in
                                if x.senderUsername != myUsername {
                                    Text(x.message)
                                    .padding()
                                    .frame(width: 200)
                                    .background(RoundedRectangle(cornerRadius: 25).fill(Color("MainColor")))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding().listRowSeparator(.hidden)
                                    .id(x.id) // this will be used by the scroller to find chats
                                } else {
                                    Text(x.message)
                                    .padding()
                                    .frame(width: 200)
                                    .background(RoundedRectangle(cornerRadius: 25).fill(.gray))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding().listRowSeparator(.hidden)
                                    .id(x.id) // this will be used by the scroller to find chats
                                }
                            }
                        }.onAppear() {
                            if let chatHistory = viewModel.allChats[String(receiverId)] {
                                if let lastChat = chatHistory.last {
                                    let lastChatId = lastChat.id

                                    // scroll to the last chat
                                    scroller.scrollTo(lastChatId)
                                }
                            }
                        }

                    TextField("New Message..", text: $newMessage)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.812))
                        ).padding()
                        .onSubmit {
                            if let chatHistory = viewModel.allChats[String(receiverId)] {
                                if let lastChat = chatHistory.last {
                                    let recUsername = lastChat.senderUsername == myUsername ? lastChat.receiverUsername : lastChat.senderUsername
                                    let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: myUsername, senderId: myAccountId)
                                    newMessage = ""

                                    // scroll to the last chat
                                    scroller.scrollTo(newChatId, anchor: .top)
                                }
                            }

//                            if let chatHistory = viewModel.allChats[String(receiverId)] {
//                                if let lastChat = chatHistory.last {
//                                    let lastChatId = lastChat.id
//
//                                    // scroll to the last chat
//                                    scroller.scrollTo(lastChatId, anchor: .top)
//                                }
//                            }

                        }
                }.onChange(of: viewModel.allChats[String(receiverId)]!){ _ in
                    if let chatHistory = viewModel.allChats[String(receiverId)] {
                        if let lastChat = chatHistory.last {
                            let lastChatId = lastChat.id

                            // scroll to the last chat
                            scroller.scrollTo(lastChatId)
                        }
                    }
                }
            }.onDisappear() {
                viewModel.listOfChats = viewModel.buildUniqueChatList()
            }
        }
    }
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel()
    static var previews: some View {
        MessageThread(receiverId: 15)
            .environmentObject(messenger)
    }
}
