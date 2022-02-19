//
//  MessageList.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageList: View {
    @Binding var tab: Int
    @EnvironmentObject var viewModel: MessagingViewModel
    @State var firstAppear = true
    var myAccountId: UInt = 16
    
    init(tab: Binding<Int>) {
        self._tab = tab
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.listOfChats, id: \.id) {x in
                if x.senderUsername == "admin" {
                    NavigationLink(destination: MessageThread(receiverId: x.recid == myAccountId ? x.senderid : x.recid)) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill").padding()

                            VStack(alignment: .leading) {
                                Text(x.receiverUsername)
                                Text(x.message)
                                    .padding(.leading)
                            }
                            Spacer()
                        }.frame(height: 70)
                    }.isDetailLink(true)
                } else {
                    NavigationLink(destination: MessageThread(receiverId: x.recid == myAccountId ? x.senderid : x.recid)) {
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill").padding()

                            VStack(alignment: .leading){
                                Text(x.senderUsername)
                                Text(x.message)
                                    .padding(.leading)
                            }

                            Spacer()
                        }.frame(height: 70)
                    }.isDetailLink(true)
                }

            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Inbox")
            
            Spacer()
        }.onAppear(){
            var tempHolder:[ChatData] = []
            // iterate through allChats
            for(_, chatHistory) in viewModel.allChats {
                tempHolder.append(chatHistory.last!)
            }
            
            viewModel.listOfChats = tempHolder.sorted(by: {$0.timestamp > $1.timestamp})
        }
        .onDisappear() {
            viewModel.newMsgCount = 0
        }
        
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(tab: Binding.constant(2))
    }
}
