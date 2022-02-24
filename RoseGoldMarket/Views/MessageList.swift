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
    @State var selection: UUID? = nil
    @State private var nextView: IdentifiableView? = nil
    var myAccountId: UInt = 16
    
    init(tab: Binding<Int>) {
        self._tab = tab
    }
    
    var body: some View {
        VStack{
            ScrollView {
                ForEach(viewModel.listOfChats, id: \.id) { x in
                    Button(action: {
                        self.nextView = IdentifiableView(
                            view: AnyView(MessageThread(receiverId: x.recid == myAccountId ? x.senderid : x.recid))
                        )
                    }, label: {
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill").padding()

                            VStack(alignment: .leading) {
                                Text(x.recid == myAccountId ? x.senderUsername : x.receiverUsername)
                                Text(x.message)
                                    .padding(.leading)
                            }

                            Spacer()
                        }.frame(height: 70)
                    })

    //                Spacer()
                }
            }.fullScreenCover(item: self.$nextView, onDismiss: { nextView = nil}) { view in
                view.view
            }
            Spacer()
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
        MessageList(tab: Binding.constant(2)).environmentObject(MessagingViewModel())
    }
}
