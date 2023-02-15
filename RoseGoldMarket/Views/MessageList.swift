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
    @EnvironmentObject var currentUser:UserModel
    
    init(tab: Binding<Int>) {
        self._tab = tab
    }
    
    var body: some View {
        NavigationView {
            VStack {
                    if !viewModel.latestMessages.isEmpty {
                        ScrollView {
                            ForEach(viewModel.latestMessages, id: \.id) { chatPreview in
                                NavigationLink(destination: MessageThread(receiverId: chatPreview.recid == currentUser.accountId ? chatPreview.senderid : chatPreview.recid, receiverUsername: chatPreview.nonViewingUsersUsername)){
                                    HStack(spacing: 10) {
                                        AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/avatars/\(chatPreview.nonViewingUsersUsername).jpg")) { phase in
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
                                            Text(chatPreview.nonViewingUsersUsername).fontWeight(.bold)
                                            HStack{
                                                Text(chatPreview.message)
                                                Spacer()
                                                Text(chatPreview.timestamp.formatted(date: .numeric, time: .omitted))
                                                    .font(.caption2)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        }
                                        Spacer()
                                        
                                    }
                                    .padding([.leading, .trailing])
                                    .frame(maxHeight: 70)
                                    .shadow(radius: 5)
                                }.isDetailLink(false)
                                Divider()
                            }
                        }
                    } else {
                        Text("No Conversations Yet").font(.largeTitle).frame(maxWidth: .infinity).fontWeight(.bold)
                    }
            }
        }
        .onAppear() {
            viewModel.getLatestMessages(viewingUser: currentUser.accountId, user: currentUser)
        }
        .onDisappear() {
            viewModel.newMsgCount = 0
        }
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(tab: Binding.constant(2))
            .environmentObject(MessagingViewModel.shared)
            .environmentObject(UserModel.shared)
    }
}
