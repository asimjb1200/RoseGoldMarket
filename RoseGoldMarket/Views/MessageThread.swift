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
     @EnvironmentObject var viewingUser:UserModel
    
    var receiverId:UInt
    var receiverUsername:String
    
    var body: some View {
        NavigationView {
            VStack{
                HStack(alignment: .top) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color("AccentColor"))
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding()
                        .onTapGesture {
                            print("back arrow tapped")
                            self.presentationMode.wrappedValue.dismiss()
                        }
                            NavigationLink(destination: AccountDetailsView(username: receiverUsername, accountid: receiverId)) {
                                Text(
                                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername == viewingUser.username ?
                                    viewModel.allChats[String(receiverId)]!.first!.senderUsername :
                                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername
                                )
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainColor"))
                                .padding()
                            }
                }
                
                ScrollViewReader { scroller in
                    VStack {
                            ScrollView {
                                ForEach(viewModel.allChats[String(receiverId)]!, id: \.id) { x in
                                    if x.senderUsername != viewingUser.username {
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
                                        let recUsername = lastChat.senderUsername == viewingUser.username ? lastChat.receiverUsername : lastChat.senderUsername
                                        
                                        let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
                                        newMessage = ""

                                        // scroll to the last chat
                                        scroller.scrollTo(newChatId, anchor: .top)
                                    }
                                }
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
            }.navigationBarHidden(true)
            Spacer()
        }.navigationViewStyle(.stack)
        
    }
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel.shared
    static var previews: some View {
        MessageThread(receiverId: 15, receiverUsername: "test3")
            .environmentObject(messenger)
    }
}
