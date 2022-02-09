//
//  MessageThread.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageThread: View {
    @State var chatThread:[ChatData]
    var myUsername = "admin"
    @State var newMessage = ""
    
    var body: some View {
        VStack {
            List(chatThread) { x in
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

            TextField("New Message..", text: $newMessage)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.812))
                ).padding()
        }
    }
}

struct MessageThread_Previews: PreviewProvider {
    static var previews: some View {
        MessageThread(chatThread: [ChatData]())
    }
}
