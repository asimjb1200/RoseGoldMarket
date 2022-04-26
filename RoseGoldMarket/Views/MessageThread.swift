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
    @EnvironmentObject var viewingUser:UserModel
    @State var tooManyChars = false
    @State var profanityFound = false
    @FocusState var messageIsFocus:Bool
    
    var receiverId:UInt
    var receiverUsername:String
    
    var body: some View {
        NavigationView {
            VStack{
                HStack(alignment: .top) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color("AccentColor"))
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding()
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                            NavigationLink(destination: AccountDetailsView(username: receiverUsername, accountid: receiverId)) {
                                Text(
                                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername == viewingUser.username ?
                                    viewModel.allChats[String(receiverId)]!.first!.senderUsername :
                                    viewModel.allChats[String(receiverId)]!.first!.receiverUsername
                                )
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainColor"))
                                .padding()
                            }
                }
                
                ScrollViewReader { scroller in
                    VStack {
                            ScrollView {
                                ForEach(viewModel.allChats[String(receiverId)]!, id: \.id) { x in
                                    if x.senderUsername != viewingUser.username {
                                        Text(x.message)
                                        .padding()
                                        .frame(width: 200)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(Color("MainColor")))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding().listRowSeparator(.hidden)
                                        .id(x.id) // this will be used by the scroller to find chats
                                    } else {
                                        Text(x.message)
                                        .padding()
                                        .frame(width: 200)
                                        .background(RoundedRectangle(cornerRadius: 25).fill(.gray))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding().listRowSeparator(.hidden)
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
                                guard profanityChecker.containsProfanity(message: newMessage) == false else {
                                    profanityFound.toggle()
                                    return
                                }
                                
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
}

struct MessageThread_Previews: PreviewProvider {
    static let messenger = MessagingViewModel.shared
    static var previews: some View {
        MessageThread(receiverId: 15, receiverUsername: "test3")
            .environmentObject(messenger)
    }
}
