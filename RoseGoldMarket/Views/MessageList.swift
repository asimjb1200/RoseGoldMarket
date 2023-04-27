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
                        List {
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
                                            if isUnreadMessage(chatPreview: chatPreview) {
                                                Text(chatPreview.nonViewingUsersUsername)
                                                    .badge(getUnreadCountForChat(chatPreview: chatPreview))
                                                    .fontWeight(.bold)
                                                    .font(.headline)
                                            } else {
                                                Text(chatPreview.nonViewingUsersUsername)
                                            }
                                            HStack {
                                                Text(chatPreview.message)
                                                Spacer()
                                                Text(chatPreview.timestamp.formatted(date: .numeric, time: .omitted))
                                                    .font(.caption2)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        }.foregroundColor(Color("MainColor"))
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing])
                                    .frame(maxHeight: 50)
                                    
                                }.isDetailLink(false)
                            }
                        }.listStyle(PlainListStyle())
                    } else {
                        Text("No Conversations Yet").font(.largeTitle).frame(maxWidth: .infinity).fontWeight(.bold)
                    }
            }
        }
        .onAppear() {
            viewModel.getLatestMessages(viewingUser: currentUser.accountId, user: currentUser)
        }
    }
}

extension MessageList {
    func isUnreadMessage(chatPreview: ChatDataForPreview) -> Bool {
        let otherUsersId = chatPreview.senderid == currentUser.accountId ? chatPreview.recid : chatPreview.senderid
        
        if let _ = viewModel.unreadMessages.first(where: {$0.senderid == otherUsersId}) {
            return true
        } else {
            return false
        }
    }
    
    func getUnreadCountForChat(chatPreview: ChatDataForPreview) -> String {
        let otherUsersId = chatPreview.senderid == currentUser.accountId ? chatPreview.recid : chatPreview.senderid
        
        let allUnreadMessagesFromUser = viewModel.unreadMessages.filter {$0.senderid == otherUsersId}
        let unreadMessagesFromUserCount = allUnreadMessagesFromUser.count

        return unreadMessagesFromUserCount > 0 ? String(unreadMessagesFromUserCount) : ""
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList(tab: Binding.constant(2))
            .environmentObject(MessagingViewModel.shared)
            .environmentObject(UserModel.shared)
    }
}
