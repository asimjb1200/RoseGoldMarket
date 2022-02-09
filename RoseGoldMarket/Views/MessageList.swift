//
//  MessageList.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageList: View {
    @Binding var tab: UInt
    @State var uniqueChats:[ChatData] = [ChatData]()
    @State var allChats: [String:[ChatData]] = [:]
    @State var firstAppear = true
    
    init(tab: Binding<UInt>) {
        self._tab = tab
    }
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack{
                    ForEach(uniqueChats, id: \.self) {x in
                        if x.senderUsername == "admin" {
                            NavigationLink(destination: MessageThread(chatThread: allChats[String(x.recid)]!)) {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill").padding()
                                    
                                    VStack(alignment: .leading){
                                        Text(x.receiverUsername)
                                        Text(x.message)
                                            .padding(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                }.frame(height: 70)
                            }
                        } else {
                            NavigationLink(destination: MessageThread(chatThread: allChats[String(x.senderid)]!)) {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill").padding()
                                    
                                    VStack(alignment: .leading){
                                        Text(x.senderUsername)
                                        Text(x.message)
                                            .padding(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                }.frame(height: 70)
                            }
                        }

                        Divider()
                    }
                }.onAppear(){
                    print("on appear running")
                    if firstAppear {
                        firstAppear = false
                        self.getAllMessages()
                    }
                    
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Inbox")
        }
    }
}

extension MessageList {
    func getAllMessages() {
        MessagingService().fetchAllThreadsForUser(userId: 16, completion: { chatResponse in
            switch(chatResponse) {
            case .success(let chatData):
                DispatchQueue.main.async {
                    print("I was called")
                    
                    // extract the last chat message from each key of the dict to use as a preview
                    for (_, chatHistory) in chatData {
                        self.uniqueChats.append(chatHistory.last!)
                    }
                    self.allChats = chatData
                    
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    print(err)
                }
            }
        })
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(tab: Binding.constant(2))
    }
}
