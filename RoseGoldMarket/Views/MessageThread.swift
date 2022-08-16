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
    var profanityChecker:InputChecker = .shared
    
    init(receiverId: UInt, receiverUsername:String) {
        UITextView.appearance().backgroundColor = .clear
        self.receiverId = receiverId
        self.receiverUsername = receiverUsername
    }
    
    var body: some View {
        NavigationView {
            VStack{
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
                .background(
                    colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white
                )
                .onAppear() {
                    // load the other user's URL
                    self.otherUsersName = getOtherUsersUsername()
                }
                
                Divider()
                
                ScrollViewReader { threadScroller in
                    VStack {
                            ScrollView {
                                ForEach(viewModel.allChats[String(receiverId)] ?? [], id: \.id) { x in
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
                                        threadScroller.scrollTo(lastChatId)
                                    }
                                }
                            }
                        //Spacer()
                        Group {
                            Divider()
                            
                            //List {
                                HStack {
                                    ScrollViewReader { textEntryScroller in
                                        ScrollView {
                                            TextEditor(text: $newMessage)
                                                .focused($messageIsFocus)
                                                .toolbar {
                                                    ToolbarItem(placement: .keyboard) {
                                                        Button("Done") {
                                                            messageIsFocus = false
                                                        }
                                                        .frame(maxWidth:.infinity, alignment:.leading)
                                                    }
                                                }.frame(height: 75)
                                        }.onChange(of: newMessage) { newChar in
                                            if newMessage.count <= 200 {
                                                return
                                            }
                                            textEntryScroller.scrollTo(newMessage.endIndex)
                                        }.frame(height: 75)
                                    }.background(RoundedRectangle(cornerRadius: 15.0).fill(.gray.opacity(0.5))).padding([.leading, .trailing]).frame(height: 75)

                                    // sits next to the text entry bubble
                                    Button("Send") {
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
                                                    threadScroller.scrollTo(newChatId, anchor: .top)
                                                } else {
                                                    let recUsername = lastChat.senderUsername
                                                    let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
                                                    newMessage = ""
                                                    // scroll to the last chat
                                                    threadScroller.scrollTo(newChatId, anchor: .top)
                                                }
                                            }
                                        }
                                    }
                                    .padding([.leading, .trailing])
                                    .accentColor(accent)
                                    .alert(isPresented: $tooManyChars) {
                                        Alert(title: Text("Over Character Limit"), message: Text("200 Characters Or Less"), dismissButton: .default(Text("OK")))
                                    }
                                }
                            //}.listStyle(PlainListStyle()).frame(height:80)
                            
                            
//                            ScrollViewReader { textEntryScroller in
//                                List {
//                                    HStack {
//                                        ScrollView {
//                                            TextEditor(text: $newMessage)
//                                                .background(
//                                                    RoundedRectangle(cornerRadius: 15.0)
//                                                    .fill(.gray.opacity(0.5))
//                                                )
//                                                .focused($messageIsFocus)
//                                                .toolbar {
//                                                    ToolbarItem(placement: .keyboard) {
//                                                        Button("Done") {
//                                                            messageIsFocus = false
//                                                        }
//                                                        .frame(maxWidth:.infinity, alignment:.leading)
//                                                    }
//                                                }
//                                        }.onChange(of: newMessage) { newChar in
//                                            textEntryScroller.scrollTo(newMessage.endIndex)
//                                        }.frame(height: 90)
//
//                                        Button("Send") {
//                                            if newMessage.count > 200 {
//                                                tooManyChars.toggle()
//                                                return
//                                            }
//
//                                            if let chatHistory = viewModel.allChats[String(receiverId)] {
//                                                if let lastChat = chatHistory.last {
//                                                    if lastChat.senderUsername == viewingUser.username {
//                                                        let recUsername = lastChat.receiverUsername
//                                                        let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
//                                                        newMessage = ""
//                                                        // scroll to the last chat
//                                                        threadScroller.scrollTo(newChatId, anchor: .top)
//                                                    } else {
//                                                        let recUsername = lastChat.senderUsername
//                                                        let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
//                                                        newMessage = ""
//                                                        // scroll to the last chat
//                                                        threadScroller.scrollTo(newChatId, anchor: .top)
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }.listStyle(PlainListStyle())
//                                .alert(isPresented: $tooManyChars) {
//                                    Alert(title: Text("Over Character Limit"), message: Text("200 Characters Or Less"), dismissButton: .default(Text("OK")))
//                                }
//                            }.frame(height: 70)
                            
//                            TextField("Enter your message...", text: $newMessage)
//                                .padding()
//                                .focused($messageIsFocus)
//                                .toolbar {
//                                    ToolbarItem(placement: .keyboard) {
//                                        Button("Done") {
//                                            messageIsFocus = false
//                                        }
//                                        .frame(maxWidth:.infinity, alignment:.leading)
//                                    }
//                                }
//                                .onSubmit {
//                                    if newMessage.count > 200 {
//                                        tooManyChars.toggle()
//                                        return
//                                    }
//
//                                    // check for profanity
////                                    guard profanityChecker.containsProfanity(message: newMessage) == false else {
////                                        profanityFound.toggle()
////                                        return
////                                    }
//
//                                    if let chatHistory = viewModel.allChats[String(receiverId)] {
//                                        if let lastChat = chatHistory.last {
//                                            let recUsername = lastChat.senderUsername == viewingUser.username ? lastChat.receiverUsername : lastChat.senderUsername
//
//                                            let newChatId = viewModel.sendMessageToUser(newMessage: newMessage, receiverId: receiverId, receiverUsername: recUsername, senderUsername: viewingUser.username, senderId: viewingUser.accountId)
//                                            newMessage = ""
//
//                                            // scroll to the last chat
//                                            scroller.scrollTo(newChatId, anchor: .top)
//                                        }
//                                    }
//                                }
//                                .background(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .fill(.gray.opacity(0.5))
//                                )
//                                .padding([.leading, .trailing])
//                                .alert(isPresented: $tooManyChars) {
//                                    Alert(title: Text("Over Character Limit"), message: Text("200 Characters Or Less"), dismissButton: .default(Text("OK")))
//                                }
//                                .frame(maxHeight: 70)
                            
                            Text("Character Limit: \(charCount - newMessage.count)")
                                .fontWeight(.light)
                                .font(.caption)
                                .frame(maxWidth: .infinity,alignment:.leading)
                                .padding([.leading, .bottom])
                                .foregroundColor(accent)
                        }
                        
                    }.onChange(of: viewModel.allChats[String(receiverId)] ?? []){ _ in
                        if let chatHistory = viewModel.allChats[String(receiverId)] {
                            if let lastChat = chatHistory.last {
                                let lastChatId = lastChat.id

                                // scroll to the last chat
                                threadScroller.scrollTo(lastChatId)
                            }
                        }
                    }
                    
                }
                .onDisappear() {
                    viewModel.listOfChats = viewModel.buildUniqueChatList()
                }
//                .alert(isPresented: $profanityFound) {
//                    Alert(title: Text("Remove your profanity"))
//                }
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
