//
//  Register.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import CoreLocation

struct Register: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel:RegisterUserViewModel = RegisterUserViewModel()
    @State var specialCharFound = false
    var inputChecker:InputChecker = .shared
    
    var body: some View {
        VStack {
            Text("Profile Picture and Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("AccentColor"))
                .alert(isPresented: $viewModel.spacesFoundInField) {
                    Alert(title: Text("Check Your Info"), message: Text("You can only have spaces in the City and Address fields. Every other field should not have spaces between words and characters."), dismissButton: .default(Text("Got It")))
                }
            
            Image(uiImage: viewModel.avatar!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        viewModel.imageEnum = .imageOne
                        viewModel.isShowingPhotoPicker = true
                    }
                    .alert(isPresented: $viewModel.specialCharFound) {
                        Alert(title: Text("No Special Characters Allowed In Username"))
                    }
            
            ScrollView {
                HStack {
                    Image(systemName: "pencil").foregroundColor(Color("MainColor"))
                    TextField("Username", text: $viewModel.username).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                .alert(isPresented: $viewModel.fieldsEmpty) {
                    Alert(title: Text("Check Your Info"), message: Text("Fill out every field in the form to sign up."), dismissButton: .default(Text("Got It")))
                }
                
                HStack {
                    Image(systemName: "key.fill").foregroundColor(Color("MainColor"))
                    SecureField("Password", text: $viewModel.password).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                .alert(isPresented: $viewModel.passwordTooShort) {
                    Alert(title: Text("Password must be 8 characters or more."))
                }
                
                HStack {
                    Text("@").foregroundColor(Color("MainColor"))
                    TextField("Email", text: $viewModel.email).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                HStack {
                    Image(systemName: "signpost.right.fill").foregroundColor(Color("MainColor"))
                    TextField("Address", text: $viewModel.address).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                HStack {
                    Image(systemName: "building.2.fill").foregroundColor(Color("MainColor"))
                    TextField("City", text: $viewModel.city)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                HStack {
                    Image(systemName: "map.fill").foregroundColor(Color("MainColor"))
                    Picker("State", selection: $viewModel.state) {
                        ForEach(viewModel.statePicker, id:\.self) {
                            Text($0)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth:.infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                .alert(isPresented: $viewModel.addressIsFake) {
                    Alert(title: Text("Your address could not be verified."))
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse").foregroundColor(Color("MainColor"))
                    TextField("Zip Code", text: $viewModel.zipCode)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding().keyboardType(.decimalPad)
                
                Button("Register") {
                    // perform make sure all fields aren't empty
                    guard viewModel.textFieldsEmpty() == false else {
                        viewModel.fieldsEmpty = true
                        return
                    }
                    
                    guard viewModel.password.count >= 8 else {
                        viewModel.passwordTooShort = true
                        return
                    }

                    guard viewModel.state != "Select A State" else {
                        return
                    }
                    
                    // the only fields that should have spaces are city and address
                    guard viewModel.spacesFound() == false else {
                        viewModel.spacesFoundInField = true
                        return
                    }

                    guard inputChecker.containsSpecialChars(text: viewModel.username) == false else {
                        viewModel.specialCharFound = true
                        return
                    }

                    viewModel.getAndSaveUserLocation()
                }.alert(isPresented: $viewModel.dataPosted) {
                    Alert(title: Text("Success"), message: Text("You've now been signed up, go back and log in."), dismissButton: .default(Text("OK"), action: { self.presentation.wrappedValue.dismiss() }))
                }
                Spacer()
            }
            
        }.sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
            PhotoPicker(plantImage: $viewModel.avatar, plantImage2: Binding.constant(nil), plantImage3: Binding.constant(nil), plantEnum: $viewModel.imageEnum)
        })
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
