//
//  AddProfilePic.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/20/22.
//

import SwiftUI

struct AddProfilePic: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var registerViewModel: RegisterUserViewModel
    @State private var wave = false
    @FocusState var focusedField:FormFields?
    @State var charCount = 16
    @State var errorOccurred = false
    @State var mustAcceptTerms = false
    @Environment(\.dismiss) private var dismiss
    
    @State var acceptedTerms = false

    let accent = Color.blue
    private let defaultImage = UIImage(named: "AddPhoto")!
    private let defaultImageLight = UIImage(named: "AddPhotoLight")!
    private let nonActiveField: some View = RoundedRectangle(cornerRadius: 30).stroke(.gray, lineWidth: 1)
    private let activeField: some View = RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth:3)
    
    var body: some View {
        VStack {
            Text("Choose Your Name and Profile Picture")
                .font(.headline)
                .padding([.leading, .trailing])
                .alert(isPresented: $errorOccurred) {
                    Alert(title: Text("An error occurred, try again later."))
                }
            
            // MARK: Avatar
            ZStack {
//                if registerViewModel.avatar == defaultImage {
//                    Circle()
//                        .fill(accent.opacity(0.25)).frame(width: 200, height: 200).scaleEffect(self.wave ? 1 : 0)
//
//
//                        Circle()
//                            .frame(width: 160, height: 160)
//                            .foregroundColor(accent)
//                            .shadow(radius: 25)
//                }
                
                switch (colorScheme) {
                    case .dark:
                        if registerViewModel.avatar == defaultImage {
//                            Circle()
//                                .fill(accent.opacity(0.25)).frame(width: 200, height: 200)

                                Circle()
                                    .frame(width: 160, height: 160)
                                    .foregroundColor(accent)
                                    .shadow(radius: 25)
                        }
                        Image(uiImage: registerViewModel.avatar!)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .frame(width: 150, height: 150)
                            .shadow(radius: 25)
                            .onTapGesture {
                                registerViewModel.imageEnum = .imageOne
                                registerViewModel.isShowingPhotoPicker = true
                            }
                            .alert(isPresented: $registerViewModel.avatarNotUploaded) {
                                Alert(title: Text("Please upload an avatar"))
                            }
                    case .light:
                        if registerViewModel.avatarLight == defaultImageLight {
//                            Circle()
//                                .fill(accent.opacity(0.25)).frame(width: 200, height: 200)

                                Circle()
                                    .frame(width: 160, height: 160)
                                    .foregroundColor(accent)
                                    .shadow(radius: 25)
                        }
                        Image(uiImage: registerViewModel.avatarLight!)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .frame(width: 150, height: 150)
                            .shadow(radius: 25)
                            .onTapGesture {
                                registerViewModel.imageEnum = .imageOne
                                registerViewModel.isShowingPhotoPicker = true
                            }
                            .alert(isPresented: $registerViewModel.avatarNotUploaded) {
                                Alert(title: Text("Please upload an avatar"))
                            }
                    @unknown default:
                        Image(uiImage: registerViewModel.avatarLight!)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .frame(width: 150, height: 150)
                            .shadow(radius: 25)
                            .onTapGesture {
                                registerViewModel.imageEnum = .imageOne
                                registerViewModel.isShowingPhotoPicker = true
                            }
                            .alert(isPresented: $registerViewModel.avatarNotUploaded) {
                                Alert(title: Text("Please upload an avatar"))
                            }
                }
            }.frame(maxHeight: 250)
            
            // MARK: Display Name
            HStack {
                Image(systemName: "pencil").foregroundColor(focusedField == FormFields.username ? accent : Color.gray)
                TextField("Display Name", text: $registerViewModel.username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .username)
                    .foregroundColor(focusedField == FormFields.username ? accent : Color.gray)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                focusedField = nil
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .padding()
            .background(focusedField == FormFields.username ? AnyView(activeField) : AnyView(nonActiveField))
            .padding([.leading, .trailing])
            .alert(isPresented: $registerViewModel.nameNotAvailable) {
                Alert(title: Text("That display name isn't available."))
            }

            Text("Character Limit: \(charCount)")
                .fontWeight(.light)
                .font(.caption)
                .frame(maxWidth: .infinity,alignment:.leading)
                .padding(.leading)
                .foregroundColor(focusedField == FormFields.username ? accent : Color.gray)
                .alert(isPresented: $registerViewModel.usernameLengthIsInvalid) {
                    Alert(title: Text("Display name must be between 5 and 16 characters."))
                }
            
            HStack(alignment: .top) {
                Rectangle()
                    .fill(acceptedTerms ? .green : .clear)
                    .frame(width: 20, height: 20)
                    .border(.gray, width: 2)
                    .onTapGesture {
                        acceptedTerms.toggle()
                    }
                
                Text("Tap here to review and accept our [Terms and Conditions](https://www.rosegoldgardens.com/privacy.html) of app usage. You will not be able to create an account without doing so.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding([.leading, .trailing, .top])
            .alert(isPresented: $mustAcceptTerms) {
                Alert(title: Text("To use this Service you must accept the Terms and Conditions of usage"), message: Text("We've made this mandatory to ensure a safe and subject matter focused marketplace for all users. This is also to try and make an effort to keep the application free of content that is obscene and/or offensive."))
            }
            
            Text("Review our [Privacy Policy](https://www.rosegoldgardens.com/privacy.html).")
                .padding(.top, 50)
                .foregroundColor(.gray)
            
            Button("Confirm Account") {
                if colorScheme == .dark {
                    guard registerViewModel.avatar != UIImage(named: "AddPhoto") else {
                        registerViewModel.avatarNotUploaded = true
                        return
                    }
                } else {
                    guard registerViewModel.avatarLight != UIImage(named: "AddPhotoLight") else {
                        registerViewModel.avatarNotUploaded = true
                        return
                    }
                }
                
                guard
                    registerViewModel.username.count <= 16,
                    registerViewModel.username.count > 5
                else {
                    registerViewModel.usernameLengthIsInvalid = true
                    focusedField = .username
                    return
                }
                
                guard
                    let addyInfo = registerViewModel.addressInfo
                else {
                    print("Couldn't get their address information.")
                    errorOccurred = true
                    return
                }
                
                guard
                    acceptedTerms == true
                else {
                    mustAcceptTerms.toggle()
                    return
                }
                
                let sanitizedPhone = registerViewModel.phone.replacingOccurrences(of: "-", with: "")
                
                if colorScheme == .light {
                    registerViewModel.registerUserV2(address: addyInfo.address, phone: sanitizedPhone, city: addyInfo.city, state: addyInfo.state, zipCode: addyInfo.zipCode, geolocation: addyInfo.geolocation)
                } else {
                    registerViewModel.registerUserV2(address: addyInfo.address, phone: sanitizedPhone, city: addyInfo.city, state: addyInfo.state, zipCode: addyInfo.zipCode, geolocation: addyInfo.geolocation, colorScheme: ColorScheme.dark)
                }
            }
            .foregroundColor(Color.white)
            .font(.system(size: 16, weight: Font.Weight.bold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: 190))
            .padding(.top, 100.0)
            .alert(isPresented: $registerViewModel.dataPosted) {
                Alert(title: Text("Success"), message: Text("Account Created"), dismissButton: .default(Text("Log In")) {
                    registerViewModel.canLoginNow = true
                    dismiss()
                })
            }.shadow(radius: 5)
            
            Spacer()
        }.tint(accent)
    }
}

struct AddProfilePic_Previews: PreviewProvider {
    static var previews: some View {
        AddProfilePic(registerViewModel: RegisterUserViewModel())
            .preferredColorScheme(.dark)
            
    }
}
