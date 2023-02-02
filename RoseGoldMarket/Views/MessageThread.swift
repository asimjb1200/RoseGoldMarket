//
//  MessageThread.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/3/22.
//

import SwiftUI

struct MessageThread: View {
    @EnvironmentObject var viewModel: MessagingViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewingUser:UserModel
    @FocusState var messageIsFocus:Bool
    @State var tooManyChars = false
    @State var profanityFound = false
    @State var otherUsersName:String = ""
    @State var newMessage = ""
    var charCount = 200

    var receiverId:UInt
    var receiverUsername:String

    var mainColor = Color("MainColor")
    var accent = Color("AccentColor")
    
    var body: some View {
        NavigationView {
            VStack (spacing: 0){
                HStack(alignment: .center) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(accent)
                        .imageScale(.large)
                        .padding()
                        .shadow(radius: 5.0)
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                    if !otherUsersName.isEmpty {
                        // present the other user's avi so that the user can tap it and go to their profile
                        NavigationLink(destination: AccountDetailsView(username: receiverUsername, accountid: receiverId)) {
                            Text(otherUsersName).foregroundColor(mainColor).fontWeight(.bold)
                            AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/avatars/\(otherUsersName).jpg")) { phase in
                                if let image = phase.image {
                                    image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                                    .padding(.trailing)
                                    .shadow(radius: 5.0)
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    ProgressView()
                                        .foregroundColor(Color("MainColor"))
                                        .frame(width: 25, height: 25)
                                }
                            }
                        }
                    }
                }
                .frame(height: 50)
                .background(
                    colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white
                )
                .onAppear() {
                    // load the other user's URL
                    self.otherUsersName = getOtherUsersUsername()
                }
                
                ScrollViewReader { scroller in
                    VStack {
                            ScrollView {
                                ForEach(viewModel.allChats[String(receiverId)]!, id: \.id) { x in
                                    if x.senderUsername != viewingUser.username {
                                        // messages coming from the other user will have the gold bg color
                                        Text(x.message)
                                        .padding()
                                        .frame(width: 200)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(mainColor))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding().listRowSeparator(.hidden)
                                        .shadow(radius: 5)
                                        .id(x.id) // this will be used by the scroller to find chats
                                    } else {
                                        // messages coming from the user on this device will have the gray bg color
                                        Text(x.message)
                                        .padding()
                                        .frame(width: 200)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(.gray))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding().listRowSeparator(.hidden)
                                        .shadow(radius: 5)
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
                        Group {
                            TextField("Enter your message...", text: $newMessage, axis: .vertical)
                                .padding()
                                .focused($messageIsFocus)
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        Button("Done") {
                                            messageIsFocus = false
                                        }
                                        .frame(maxWidth:.infinity, alignment:.leading)
                                    }
                                }
                                .onSubmit {
                                    if newMessage.count > 200 {
                                        tooManyChars.toggle()
                                        return
                                    }
                                    

                                    if let chatHistory = viewModel.allChats[String(receiverId)] {
                                        if let lastChat = chatHistory.last {
                                            if lastChat.senderUsername == viewingUser.username {
                                                let recUsername = lastChat.receiverUsername
                                                let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
                                                newMessage = ""
                                                // scroll to the last chat
                                                scroller.scrollTo(newChatId, anchor: .top)
                                            } else {
                                                let recUsername = lastChat.senderUsername
                                                let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
                                                newMessage = ""
                                                // scroll to the last chat
                                                scroller.scrollTo(newChatId, anchor: .top)
                                            }
                                        }
                                    }
                                }
                                .onChange(of: newMessage) {
                                    // limit to 200 characters
                                    newMessage = String($0.prefix(200))
                                }
                                .modifier(CustomTextBubble(isActive: messageIsFocus == true, accentColor: .blue))
                                .padding([.leading, .trailing])
                                .alert(isPresented: $tooManyChars) {
                                    Alert(title: Text("Over Character Limit"), message: Text("200 Characters Or Less"), dismissButton: .default(Text("OK")))
                                }
                                .lineLimit(5)
                            
                            Text("Character Limit: \(charCount - newMessage.count)")
                                .fontWeight(.light)
                                .font(.caption)
                                .frame(maxWidth: .infinity,alignment:.leading)
                                .padding([.leading, .bottom])
                                .foregroundColor(accent)
                        }
                        
                    }
                    .onChange(of: viewModel.allChats[String(receiverId)]!) { _ in
                        if let chatHistory = viewModel.allChats[String(receiverId)] {
                            if let lastChat = chatHistory.last {
                                let lastChatId = lastChat.id

                                // scroll to the last chat
                                scroller.scrollTo(lastChatId)
                            }
                        }
                    }
                    
                }
                .onDisappear() {
                    viewModel.listOfChats = viewModel.buildUniqueChatList()
                }
            }.navigationBarHidden(true)
            Spacer()
        }.navigationViewStyle(.stack)
        
    }
    
    func getOtherUsersUsername() -> String {
        guard let allChats = viewModel.allChats[String(receiverId)] else {
            return ""
        }
        guard let firstChatInThisThread = allChats.first else {
            return ""
        }
        let otherUsersUsername = firstChatInThisThread.receiverUsername == viewingUser.username ? firstChatInThisThread.senderUsername : firstChatInThisThread.receiverUsername
        return otherUsersUsername
    }
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel.shared
    static var previews: some View {
        MessageThread(receiverId: 15, receiverUsername: "test3")
            .environmentObject(messenger)
    }
}
