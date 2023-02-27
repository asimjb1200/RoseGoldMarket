//
//  ChangeUsername.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/17/23.
//

import SwiftUI
import Combine

struct ChangeUsername: View {
    @EnvironmentObject var user:UserModel
    @Environment(\.dismiss) private var dismiss
    @FocusState var focusField:Bool?
    @State var newUsername = ""
    @State var isAvailable = false
    @State var successful = false
    @State var loading = false
    @State var debouncedText = ""
    @State var problemOccurred = false
    
    let searchTextPublisher = PassthroughSubject<String, Never>()
    let userService = UserNetworking.shared
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(user.username)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .alert(isPresented: $successful) {
                    Alert(title: Text("Name Change Successful"), dismissButton: .default(Text("OK"), action: { dismiss() }))
                }
            
            TextField("\(user.username)", text: $newUsername)
                .textInputAutocapitalization(.never)
                .focused($focusField, equals: true)
                .padding()
                .modifier(CustomTextBubble(isActive: focusField == true, accentColor: .blue))
                .padding()
                .onChange(of: newUsername) {
                    newUsername = String($0.prefix(16))
                    searchTextPublisher.send(newUsername)
                }
                .onReceive(searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { debouncedSearchText in
                    debouncedText = debouncedSearchText
                    if debouncedText.count > 5 {
                        checkAvailability(usernameToCheck: debouncedSearchText.lowercased())
                    }
                }

            if debouncedText.count > 5 {
                if loading {
                    ProgressView("Working...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                } else {
                    Text(isAvailable ? "Available" : "Unavailable")
                        .foregroundColor(isAvailable ? .green : .red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                }
            } else {
                Text("6 or more characters")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
            }
            
            Button(
                action: {
                    guard debouncedText.count > 5 else {
                        return
                    }
                    
                    guard isAvailable else {
                        return
                    }
                    
                    // save the user name
                    saveUsername(newUsername: debouncedText)
                },
                label: {
                    Text("Save")
                        .foregroundColor(isAvailable && debouncedText.count > 5 ? Color.white : Color(.systemGray6))
                        .frame(width: buttonWidth)
                        .font(.system(size: 16, weight: Font.Weight.bold))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(isAvailable  && debouncedText.count > 5 ? Color.blue : .gray).frame(width: buttonWidth))
                        .padding(.top)
                        .disabled(!isAvailable  && debouncedText.count > 5)
                }
            ).alert(isPresented: $problemOccurred) {
                Alert(title: Text("Name Change Unsuccessful"), message: Text("Try again later"), dismissButton: .default(Text("OK")) )
            }
        }.navigationBarTitle(Text("Change Username"), displayMode: .inline)
    }
    
    func checkAvailability(usernameToCheck: String) {
        self.loading = true
        userService.checkUsernameAvailability(newUsername: usernameToCheck, token: user.accessToken) { isAvailableResponse in
            switch isAvailableResponse {
                case .success(let usernameFound):
                    DispatchQueue.main.async {
                        if usernameFound == "0" {
                            isAvailable = true
                        } else {
                            isAvailable = false
                        }
                        self.loading = false
                    }
            case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                        isAvailable = false
                    }
            }
        }
    }
    
    func saveUsername(newUsername: String) {
        userService.saveNewUsername(newUsername: debouncedText, oldUsername: user.username, accessToken: user.accessToken) { nameChangeResponse in
            switch nameChangeResponse {
                case .success(let nameChanged):
                    if nameChanged.data == true {
                        DispatchQueue.main.async {
                            if nameChanged.newToken != nil {
                                user.accessToken = nameChanged.newToken!
                            }
                            successful = true
                            user.updateUserName(newUsername: newUsername)
                        }
                    }
                case .failure(let err):
                    print(err)
            }
            
        }
    }
}

struct ChangeUsername_Previews: PreviewProvider {
    static var previews: some View {
        ChangeUsername().environmentObject(UserModel.shared)
    }
}
