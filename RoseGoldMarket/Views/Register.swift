//
//  Register.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import CoreLocation

struct Register: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel:RegisterUserViewModel = RegisterUserViewModel()
    @State var specialCharFound = false
    private enum FormFields: Int, CaseIterable {
        case firstName, lastName, username, address, password, email, city, zipcode
    }
    @FocusState private var focusedField:FormFields?
    var charCount = 16
    var inputChecker:InputChecker = .shared
    var gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    var accent = Color("AccentColor")
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.avatar!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        viewModel.imageEnum = .imageOne
                        viewModel.isShowingPhotoPicker = true
                    }
                    .alert(isPresented: $viewModel.avatarNotUploaded) {
                        Alert(title: Text("Please upload an avatar"))
                    }

            ScrollView {
                Group {
                    TextField("", text: $viewModel.firstName)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.firstName.isEmpty, placeHolder: "First Name..."))
                        .padding()
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .firstName)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(gradient)
                        )
                        .padding()
                        
                    
                    TextField("", text: $viewModel.lastName)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.lastName.isEmpty, placeHolder: "Last Name..."))
                        .padding()
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .lastName)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(gradient)
                        )
                        .padding([.leading, .trailing, .bottom])
                }.alert(isPresented: $viewModel.specialCharFound) {
                    Alert(title: Text("No Special Characters Allowed In Username, first name or last name fields"))
                }
                
                
                // username
                Group {
                    HStack {
                        Image(systemName: "pencil").foregroundColor(accent)
                        TextField("", text: $viewModel.username)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.username.isEmpty, placeHolder: "Username..."))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .username)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Button("Done") {
                                        focusedField = nil
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(gradient)
                    )
                    .padding([.leading, .trailing])
                    .alert(isPresented: $viewModel.fieldsEmpty) {
                        Alert(title: Text("Check Your Info"), message: Text("Fill out every field in the form to sign up."), dismissButton: .default(Text("Got It")))
                    }
                    
                    Text("Character Limit: \(charCount)")
                        .fontWeight(.light)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment:.leading)
                        .padding(.leading)
                        .foregroundColor(accent)
                        .alert(isPresented: $viewModel.usernameLengthIsInvalid) {
                            Alert(title: Text("Username must be between 8 and 16 characters."))
                        }
                }

                // password
                Group {
                    HStack {
                        Image(systemName: "key.fill").foregroundColor(accent)
                        SecureField("", text: $viewModel.password)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.password.isEmpty, placeHolder: "Password..."))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .password)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(gradient)
                    )
                    .padding([.leading, .trailing, .top])
                    .alert(isPresented: $viewModel.passwordNotComplex) {
                        Alert(title: Text("Password must be between 8 and 16 characters and contain at least 1 number and 1 uppercase letter."))
                    }
                    
                    Text("Character Limit: \(charCount). 1 number and 1 uppercase letter needed")
                        .fontWeight(.light)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment:.leading)
                        .padding(.leading)
                        .foregroundColor(accent)
                        .alert(isPresented: $viewModel.passwordLengthIsInvalid) {
                            Alert(title: Text("Password must be between 8 and 16 characters."))
                        }
                }
                
                HStack {
                    Text("@").foregroundColor(accent)
                    TextField("", text: $viewModel.email)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.email.isEmpty, placeHolder: "Email..."))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                
                HStack {
                    Image(systemName: "signpost.right.fill").foregroundColor(accent)
                    TextField("Address", text: $viewModel.address)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.address.isEmpty, placeHolder: "Address..."))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .address)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                
                HStack {
                    Image(systemName: "building.2.fill").foregroundColor(accent)
                    TextField("City", text: $viewModel.city)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.city.isEmpty, placeHolder: "City..."))
                        .focused($focusedField, equals: .city)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                
                HStack {
                    Image(systemName: "map.fill").foregroundColor(accent)
                    Picker("State", selection: $viewModel.state) {
                        ForEach(viewModel.statePicker, id:\.self) {
                            Text($0)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth:.infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding()
                .alert(isPresented: $viewModel.addressIsFake) {
                    Alert(title: Text("Your address could not be verified."))
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse").foregroundColor(accent)
                    TextField("", text: $viewModel.zipCode)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.zipCode.isEmpty, placeHolder: "Zip Code..."))
                        .focused($focusedField, equals: .zipcode)
                        .alert(isPresented: $viewModel.spacesFoundInField) {
                            Alert(title: Text("Check Your Info"), message: Text("You can only have spaces in the City and Address fields. Every other field should not have spaces between words and characters."), dismissButton: .default(Text("Got It")))
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(gradient)
                )
                .padding().keyboardType(.decimalPad)
                
                Button("Register") {
                    guard viewModel.avatar != UIImage(named: "default") else {
                        viewModel.avatarNotUploaded = true
                        return
                    }
                    // make sure all fields aren't empty
                    guard viewModel.textFieldsEmpty() == false else {
                        viewModel.fieldsEmpty = true
                        return
                    }

                    guard
                        viewModel.password.count >= 8,
                        viewModel.password.count <= 16
                    else {
                        viewModel.passwordLengthIsInvalid = true
                        return
                    }

                    guard viewModel.pwContainsUppercase() else {
                        viewModel.passwordNotComplex = true
                        return
                    }

                    guard viewModel.pwContainsNumber() else {
                        viewModel.passwordNotComplex = true
                        return
                    }

//                    guard viewModel.containsEnoughChars(text: viewModel.password) else {
//                        viewModel.passwordNotComplex = true
//                        return
//                    }

                    guard
                        viewModel.username.count <= 16,
                        viewModel.username.count > 7
                    else {
                        viewModel.usernameLengthIsInvalid = true
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

                    guard
                        inputChecker.containsSpecialChars(text: viewModel.username) == false
                    else {
                        viewModel.specialCharFound = true
                        return
                    }

                    viewModel.getAndSaveUserLocation()
                }.alert(isPresented: $viewModel.dataPosted) {
                    Alert(title: Text("Success"), message: Text("You've now been signed up, go back and log in."), dismissButton: .default(Text("OK"), action: { dismiss() }))
                }
                Spacer()
                .alert(isPresented: $viewModel.nameNotAvailable) {
                    Alert(title: Text("Username Not Available"))
                }
            }.navigationBarTitle("Information", displayMode: .inline)
            
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
