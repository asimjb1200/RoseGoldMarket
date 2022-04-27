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
    var profanityChecker:InputChecker = .shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewingUser:UserModel
    @State var tooManyChars = false
    @State var profanityFound = false
    @FocusState var messageIsFocus:Bool
    
    var receiverId:UInt
    var receiverUsername:String
    @State var otherUsersName:String = ""
    
    var body: some View {
        NavigationView {
            VStack{
                HStack(alignment: .center) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color("AccentColor"))
                        .imageScale(.large)
                        .padding()
                        .shadow(radius: 5.0)
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                    if !otherUsersName.isEmpty {
                        // present the other user's avi so that the user can tap it and go to their profile
                        NavigationLink(destination: AccountDetailsView(username: receiverUsername, accountid: receiverId)) {
                            AsyncImage(url: URL(string: "https://rosegoldgardens.com/api/images/avatars/\(otherUsersName).jpg")) { phase in
                                if let image = phase.image {
                                    image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 60, height: 60)
                                    .padding()
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
                .background(
                    colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white
                )
                .onAppear() {
                    // load the other user's URL
                    self.otherUsersName = getOtherUsersUsername()
                }
                
                Divider()
                
                ScrollViewReader { scroller in
                    VStack {
                            ScrollView {
                                ForEach(viewModel.allChats[String(receiverId)]!, id: \.id) { x in
                                    if x.senderUsername != viewingUser.username {
                                        // messages coming from the other user will have the gold bg color
                                        Text(x.message)
                                        .padding()
                                        .frame(width: 200)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(Color("MainColor")))
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
                            Divider()
                            TextField("New Message..", text: $newMessage)
                                .padding()
                                .textFieldStyle(OvalTextFieldStyle())
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
                                    
                                    // check for profanity
//                                    guard profanityChecker.containsProfanity(message: newMessage) == false else {
//                                        profanityFound.toggle()
//                                        return
//                                    }
                                    
                                    if let chatHistory = viewModel.allChats[String(receiverId)] {
                                        if let lastChat = chatHistory.last {
                                            let recUsername = lastChat.senderUsername == viewingUser.username ? lastChat.receiverUsername : lastChat.senderUsername
                                            
                                            let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
                                            newMessage = ""

                                            // scroll to the last chat
                                            scroller.scrollTo(newChatId, anchor: .top)
                                        }
                                    }
                                }
                                .alert(isPresented: $tooManyChars) {
                                    Alert(title: Text("Over Character Limit"), message: Text("200 Characters Or Less"), dismissButton: .default(Text("OK")))
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
                    
                }
                .onDisappear() {
                    viewModel.listOfChats = viewModel.buildUniqueChatList()
                }
                .alert(isPresented: $profanityFound) {
                    Alert(title: Text("Remove your profanity"))
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
