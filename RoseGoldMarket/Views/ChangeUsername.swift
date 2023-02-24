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
    @FocusState var focusField:Bool?
    @State var newUsername = ""
    @State var isAvailable = false
    @State var nameChanged = false
    @State var loading = false
    @State var debouncedText = ""
    
    let searchTextPublisher = PassthroughSubject<String, Never>()
    let userService = UserNetworking.shared
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(user.username)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("\(user.username)", text: $newUsername)
                .focused($focusField, equals: true)
                .padding()
                .modifier(CustomTextBubble(isActive: focusField == true, accentColor: .blue))
                .padding()
                .onChange(of: newUsername) {
                    newUsername = String($0.prefix(16))
                    if newUsername.count > 5 {
                        searchTextPublisher.send(newUsername)
                    }
                }
                .onReceive(searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { debouncedSearchText in
                    debouncedText = debouncedSearchText
                    checkAvailability(usernameToCheck: debouncedSearchText.lowercased())
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
            }
            
            Button(
                action: {
                    guard isAvailable else {
                        return
                    }
                    
                    // save the user name
                    
                },
                label: {
                    Text("Save")
                        .foregroundColor(isAvailable ? Color.white : Color(.systemGray6))
                        .frame(width: buttonWidth)
                        .font(.system(size: 16, weight: Font.Weight.bold))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(isAvailable ? Color.blue : .gray).frame(width: buttonWidth))
                        .padding(.top)
                        .disabled(isAvailable)
                }
            )
        }
    }
    
    func checkAvailability(usernameToCheck: String) {
        self.loading = true
        userService.checkUsernameAvailability(newUsername: usernameToCheck) { isAvailableResponse in
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
        
    }
}

struct ChangeUsername_Previews: PreviewProvider {
    static var previews: some View {
        ChangeUsername().environmentObject(UserModel.shared)
    }
}
