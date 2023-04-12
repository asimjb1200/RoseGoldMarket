//
//  AccountOptions.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI
import MessageUI

struct AccountOptions: View {
    @EnvironmentObject var user:UserModel
    @EnvironmentObject var messenger:MessagingViewModel
    @StateObject var emailer = EmailService()
    @Environment(\.openURL) var openURL
    @State var confirmLogout = false
    @State var confirmDeletion = false
    @State var deletetionErrorOccurred = false
    @State var emailSent = false
    @State var showSheet = false
    var service:UserNetworking = .shared
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(
                        content: {
                            NavigationLink(destination: ChangeLocation(), label: {Text("Change Address")})
                            
                            NavigationLink(destination: ChangeAvatar(), label: {Text("Change Profile Picture")})

                            NavigationLink(destination: MyListings(), label: {Text("My Listings")})
                            
                            NavigationLink(destination: ChangeUsername(), label: {Text("Change Display Name")})
                        },
                        header: {
                            Text("My Account").font(.title).fontWeight(.bold)
                        }
                    )
                    
                    Section(
                        content: {
                            Button("Email Support") {
                                if MFMailComposeViewController.canSendMail() {
                                    emailer.sendEmail(subject: "Inquiry From \(user.username)", body: "", to: "support@rosegoldgardens.com") { _ in
                                        
                                    }
                                } else { // if they don't have the apple mail app on their phone
                                    openURL(URL(string: "mailto:support@rosegoldgardens.com?subject=Inquiry%20From%20\(user.username)")!)
                                }
                            }
                            .alert(isPresented: $emailer.emailSent) {
                                Alert(title: Text("Your Message Was Delivered"))
                            }
                            
                            Button("Log Out") {
                                confirmLogout.toggle()
                            }
                            .alert(isPresented: $confirmLogout){
                                Alert(title: Text("Are You Sure?"), primaryButton: .default(Text("Yes"), action: {
                                    // clear out the chat stuff
                                    messenger.currentlyActiveChat = []
                                    messenger.latestMessages = []
                                    
                                    user.logout()
                                }),
                                      secondaryButton: .cancel()
                                )
                            }
                            
                            Button("Delete Account") {
                                confirmDeletion.toggle()
                            }
                            .foregroundColor(.red)
                            .alert(isPresented: $confirmDeletion) {
                                Alert(
                                    title: Text("Are You Sure?"),
                                    message: Text("Your account can't be recovered if you move forward."),
                                    primaryButton:
                                            .default(Text("Delete").foregroundColor(.red),
                                            action: {
                                                self.deleteAccount()
                                            }),
                                    secondaryButton: .cancel())
                            }
                        },
                        header: {
                            Text("Account Actions").font(.title).fontWeight(.bold)
                        }
                    )
                }
                .alert(isPresented: $deletetionErrorOccurred) {
                    Alert(title:Text("An Error Occurred"), message: Text("Try again later."))
                }
            }
        }.navigationBarHidden(true).navigationViewStyle(.stack)
    }
}

extension AccountOptions {
    func deleteAccount() {
        self.service.deleteUser(token: user.accessToken) { deletionResponse in
            switch deletionResponse {
                case .success( _):
                    DispatchQueue.main.async {
                        self.user.logout()
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                    }
            }
        }
    }
}

struct AccountOptions_Previews: PreviewProvider {
    static var previews: some View {
        AccountOptions()
            .environmentObject(UserModel.shared)
            .environmentObject(MessagingViewModel.shared)
    }
}
