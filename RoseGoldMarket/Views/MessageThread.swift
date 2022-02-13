//
//  MessageThread.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageThread: View {
//    @State var chatThread:[ChatData]
    var myUsername = "admin"
    @State var newMessage = ""
    @EnvironmentObject var viewModel: MessagingViewModel
    var receiverId:UInt
//    @EnvironmentObject var socket: SocketUtils
    
    var body: some View {
        VStack {
                ScrollView {
                    ForEach(viewModel.allChats[String(receiverId)]!, id: \.customId) { x in
                        if x.senderUsername != myUsername {
                            Text(x.message)
                            .padding()
                            .frame(width: 200)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("MainColor")))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding().listRowSeparator(.hidden)
                        } else {
                            Text(x.message)
                            .padding()
                            .frame(width: 200)
                            .background(RoundedRectangle(cornerRadius: 25).fill(.gray))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding().listRowSeparator(.hidden)
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
                    print("user submitted")
                }
        }
    }
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel()
    static var previews: some View {
        let chats = [
            ChatData(id: 1, senderid: 15, recid: 16, message: "HEY", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
            ChatData(id: 2, senderid: 16, recid: 15, message: "Hey", timestamp: Date(), senderUsername: "test", receiverUsername: "admin"),
            ChatData(id: 3, senderid: 15, recid: 16, message: "what do you have?", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
            ChatData(id: 4, senderid: 15, recid: 16, message: "I need something pink and easy to care for", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
            ChatData(id: 5, senderid: 16, recid: 15, message: "I have a few daisies and some more roses", timestamp: Date(), senderUsername: "test", receiverUsername: "admin"),
            ChatData(id: 6, senderid: 15, recid: 16, message: "Can you send a few pics of them? that seems like it may work", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
            ChatData(id: 7, senderid: 15, recid: 16, message: "Can you send a few pics of them? that seems like it may work", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
            ChatData(id: 8, senderid: 15, recid: 16, message: "Can you send a few pics of them? that seems like it may work", timestamp: Date(), senderUsername: "admin", receiverUsername: "test"),
        ]
        
        MessageThread(receiverId: 15)
            .environmentObject(messenger)
    }
}
