//
//  MessageList.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageList: View {
    @Binding var tab: Int
    @State var firstAppear = true
    @State var selection: UUID? = nil
    @State private var nextView: IdentifiableView? = nil
    @EnvironmentObject var viewModel: MessagingViewModel
    @EnvironmentObject var user:UserModel
    
    init(tab: Binding<Int>) {
        self._tab = tab
    }
    
    var body: some View {
        VStack{
            if !viewModel.listOfChats.isEmpty {
                ScrollView {
                    ForEach(viewModel.listOfChats, id: \.id) { x in
                        Button(action: {
                            self.nextView = IdentifiableView(
                                view: AnyView(
                                    MessageThread(receiverId: x.recid == user.accountId ? x.senderid : x.recid,
                                                  receiverUsername: x.recid == user.accountId ? x.senderUsername : x.receiverUsername))
                            )
                        }, label: {
                            HStack(spacing: 10) {
                                AsyncImage(url: URL(string: "http://localhost:4000/images/avatars/\(x.recid == user.accountId ? x.senderUsername : x.receiverUsername).jpg")) { phase in
                                    if let image = phase.image {
                                        image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 60, height: 60)
                                    } else if phase.error != nil {
                                        Color.red
                                    } else {
                                        ProgressView()
                                            .foregroundColor(Color("MainColor"))
                                            .frame(width: 25, height: 25)
                                    }
                                }

                                VStack(alignment: .leading) {
                                    Text(x.recid == user.accountId ? x.senderUsername : x.receiverUsername)
                                    Text(x.message)
                                        .padding(.leading)
                                }

                                Spacer()
                            }.frame(height: 70)
                        })
                    }
                }.fullScreenCover(item: self.$nextView, onDismiss: { nextView = nil}) { view in
                    view.view
                }
                Spacer()
            } else {
                Text("No Conversations Yet")
                .fontWeight(.bold)
                .foregroundColor(Color("MainColor"))
            }
        }
        .padding()
        .onDisappear() {
            viewModel.newMsgCount = 0
        }
    }
    
    func buildUniqueChatList() -> [ChatData] {
        var tempHolder:[ChatData] = []
        // iterate through allChats
        for(_, chatHistory) in self.viewModel.allChats {
            tempHolder.append(chatHistory.last!)
        }

        return tempHolder.sorted(by: {$0.timestamp > $1.timestamp})
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(tab: Binding.constant(2)).environmentObject(MessagingViewModel.shared)
    }
}
