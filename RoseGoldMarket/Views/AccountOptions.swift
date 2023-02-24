//
//  AccountOptions.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI

struct AccountOptions: View {
    @EnvironmentObject var user:UserModel
    @State var confirmLogout = false
    @State var confirmDeletion = false
    @State var deletetionErrorOccurred = false
    var service:UserNetworking = .shared
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(
                        content: {
                            NavigationLink(destination: ChangeLocation(), label: {Text("Change Your Location")})
                            
                            NavigationLink(destination: ChangeAvatar(), label: {Text("Change Your Profile Picture")})

                            NavigationLink(destination: MyListings(), label: {Text("My Listings")})
                            
                            NavigationLink(destination: ChangeUsername(), label: {Text("\(user.username)")})
                        },
                        header: {
                            Text("My Account").font(.title).fontWeight(.bold)
                        }
                    )
                    
                    Section(
                        content: {
                            NavigationLink(destination: EmailSupport(), label: {Text("Email Support")})
                            
                            Button("Log Out") {
                                confirmLogout.toggle()
                            }
                            .alert(isPresented: $confirmLogout){
                                Alert(title: Text("Are You Sure?"), primaryButton: .default(Text("Yes"), action: {
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
                }.alert(isPresented: $deletetionErrorOccurred) {
                    Alert(title:Text("An Error Occurred"), message: Text("Try again later."))
                }
            }
        }.navigationBarHidden(true)
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
    }
}
