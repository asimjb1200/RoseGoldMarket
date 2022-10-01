//
//  AddProfilePic.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/20/22.
//

import SwiftUI

struct AddProfilePic: View {
    @StateObject var registerViewModel: RegisterUserViewModel
    @State private var wave = false
    @FocusState var focusedField:FormFields?
    @State var charCount = 16
    @State var errorOccurred = false
    @Environment(\.dismiss) private var dismiss

    let accent = Color.blue
    private let defaultImage = UIImage(named: "AddPhoto")!
    private let nonActiveField: some View = RoundedRectangle(cornerRadius: 30).stroke(.gray, lineWidth: 1)
    private let activeField: some View = RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth:3)
    
    var body: some View {
        VStack {
            Text("Choose Your Name and Profile Picture")
                .font(.headline)
                .alert(isPresented: $errorOccurred) {
                    Alert(title: Text("An error occurred, try again later."))
                }
            
            // MARK: Avatar
            ZStack {
                // now let's perform checks to only pulsate if the default image is up
                if registerViewModel.avatar == defaultImage {
                    Circle()
                        .fill(accent.opacity(0.25)).frame(width: 200, height: 200).scaleEffect(self.wave ? 1 : 0)
                        

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
            }.frame(maxHeight: 250)
            
            // MARK: Display Name
            HStack {
                Image(systemName: "pencil").foregroundColor(focusedField == FormFields.username ? accent : Color.gray)
                TextField("Display Name", text: $registerViewModel.username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .username)
                    .foregroundColor(Color.blue)
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
            
            Button("Confirm Account") {
                guard registerViewModel.avatar != UIImage(named: "AddPhoto") else {
                    registerViewModel.avatarNotUploaded = true
                    return
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
                
                registerViewModel.registerUserV2(address: addyInfo.address, phone: registerViewModel.phone, city: addyInfo.city, state: addyInfo.state, zipCode: addyInfo.zipCode, geolocation: addyInfo.geolocation)
            }
            .foregroundColor(Color.white)
            .font(.system(size: 16, weight: Font.Weight.bold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
            .padding(.top, 100.0)
            .alert(isPresented: $registerViewModel.dataPosted) {
                Alert(title: Text("Success"), message: Text("Account Created"), dismissButton: .default(Text("Log In")) {
                    registerViewModel.canLoginNow = true
                    dismiss()
                })
            }
            
            Spacer()
        }.shadow(radius: 5)
    }
}

struct AddProfilePic_Previews: PreviewProvider {
    static var previews: some View {
        AddProfilePic(registerViewModel: RegisterUserViewModel())
    }
}
