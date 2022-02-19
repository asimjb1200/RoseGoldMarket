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
    // @EnvironmentObject var user:UserModel
    
    var myUsername = "admin"
    var receiverId:UInt
    
    var body: some View {
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
                        let copyMyUsernames = viewModel.allChats[String(receiverId)]!.first(where: {$0.recid == receiverId})
                        if let copyMyUsernames = copyMyUsernames {
                            viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: copyMyUsernames.receiverUsername, senderUsername: copyMyUsernames.senderUsername, senderId: copyMyUsernames.senderid)
                            newMessage = ""
                        }
                        
                        if let chatHistory = viewModel.allChats[String(receiverId)] {
                            if let lastChat = chatHistory.last {
                                let lastChatId = lastChat.id
                                
                                // scroll to the last chat
                                scroller.scrollTo(lastChatId, anchor: .top)
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
            // update the unique chats list now so it won't pull the user out on each message update
            var tempHolder:[ChatData] = []
            // iterate through allChats
            for(_, chatHistory) in viewModel.allChats {
                tempHolder.append(chatHistory.last!)
            }
            viewModel.listOfChats = tempHolder.sorted(by: {$0.timestamp > $1.timestamp})
        }
    }
    
    func updateChatHistory() {
        
    }
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel()
    static var previews: some View {
        MessageThread(receiverId: 15)
            .environmentObject(messenger)
    }
}
