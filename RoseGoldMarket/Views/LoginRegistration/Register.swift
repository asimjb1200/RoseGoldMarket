//
//  Register.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit


struct Register: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel:RegisterUserViewModel = RegisterUserViewModel()
    @State var specialCharFound = false
    @State private var wave = false
    @FocusState private var focusedField:FormFields?
    @State private var capLetterFound = false
    @State private var numberFound = false
    @State private var pwNotValid = false
    @State private var namesTooShort = false
    @StateObject private var mapSearch = MapSearch()
    @State private var oldAddyString = ""
    
    private let nonActiveField: some View = RoundedRectangle(cornerRadius: 30).stroke(.gray, lineWidth:1)
    private let activeField: some View = RoundedRectangle(cornerRadius: 30).stroke(Color("MainColor"), lineWidth:3)
    private let suggestionsListOutline: some View = RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1)

    private let defaultImage = UIImage(named: "AddPhoto")!
    private let dividerView: some View = Divider().frame(height: 5).background(Color("AccentColor"))
    private let gradientBG: some View = RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [.white, Color("MainColor")]), startPoint: .leading, endPoint: .trailing))
    private enum FormFields: Int, CaseIterable {
        case fullName, username, address, password, email, city, zipcode, state
    }
    var charCount = 16
    var inputChecker:InputChecker = .shared
    let gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    let accent = Color("AccentColor")
    
    var body: some View {
        VStack {
            ScrollView {
                // profile picture
                Group {
                    Text("Let's Get Started!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Create a Rose Gold account to access the market.")
                        .font(.caption)
                }
                // MARK: Avatar
                Group {
                    ZStack {
                        // now let's perform checks to only pulsate if the default image is up
                        if viewModel.avatar == defaultImage {
                            Circle()
                                .stroke(lineWidth: 40)
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color("AccentColor"))
                                .scaleEffect(wave ? 1 : 0.5)
                               .opacity(wave ? 0.1 : 1)
                                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(0.5), value: wave)
                                .onAppear() {
                                    self.wave.toggle()
                                }
                            
//                            Circle()
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(accent)
//                                .shadow(radius: 25)
                        }
                        
                        Image(uiImage: viewModel.avatar!)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 25)
                                .onTapGesture {
                                    viewModel.imageEnum = .imageOne
                                    viewModel.isShowingPhotoPicker = true
                                }
                                .alert(isPresented: $viewModel.avatarNotUploaded) {
                                    Alert(title: Text("Please upload an avatar"))
                                }
                    }
                }
                
                // MARK: first and last name
                HStack {
                    TextField("First Name", text: $viewModel.firstName)
                    
                    TextField("Last Name", text: $viewModel.lastName)
                }
                .padding()
                .overlay(focusedField == FormFields.fullName ? AnyView(activeField) : AnyView(nonActiveField))
                .focused($focusedField, equals: .fullName)
                .padding()
                .alert(isPresented: $namesTooShort) {
                    Alert(title: Text("Names Too Short"), message: Text("Your first and last names must be at least 2 characters each."))
                }
                
                // MARK: username
                Group {
                    HStack {
                        Image(systemName: "pencil").foregroundColor(accent)
                        TextField("", text: $viewModel.username)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.username.isEmpty, placeHolder: "Display Name"))
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
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    .padding()
                    .overlay(focusedField == FormFields.username ? AnyView(activeField) : AnyView(nonActiveField))
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
                            Alert(title: Text("Display name must be between 8 and 16 characters."))
                        }
                }

                // MARK: password
                Group {
                    if viewModel.showPW == false {
                        HStack {
                            Image(systemName: "key.fill").foregroundColor(accent)
                            SecureField("", text: $viewModel.password)
                                .onChange(of: viewModel.password) {
                                    self.capLetterFound = false
                                    self.numberFound = false
                                    for char in $0 {
                                        if char.isUppercase {
                                            self.capLetterFound = true
                                        }
                                        if char.isNumber {
                                            self.numberFound = true
                                        }
                                    }
                                    
                                    viewModel.password = String($0.prefix(16)) // this limits the char field to 16 chars
                                }
                                .modifier(PlaceholderStyle(showPlaceHolder: viewModel.password.isEmpty, placeHolder: "Password"))
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .email
                                }
                            
                            Image(systemName: "eye").foregroundColor(accent).onTapGesture { viewModel.showPW.toggle() }
                        }
                        .padding()
                        .overlay(focusedField == FormFields.password ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top])
                    } else {
                        HStack {
                            Image(systemName: "key.fill").foregroundColor(accent)
                            TextField("", text: $viewModel.password)
                                .onChange(of: viewModel.password) {
                                    self.capLetterFound = false
                                    self.numberFound = false
                                    for char in $0 {
                                        if char.isUppercase {
                                            self.capLetterFound = true
                                        }

                                        if char.isNumber {
                                            self.numberFound = true
                                        }

                                        // get the prompts to disappear if they're visible
                                        if self.numberFound && self.capLetterFound {
                                            pwNotValid = false
                                        }
                                    }
                                    
                                    viewModel.password = String($0.prefix(16)) // this limits the char field to 16 chars
                                }
                                .modifier(PlaceholderStyle(showPlaceHolder: viewModel.password.isEmpty, placeHolder: "Password..."))
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .email
                                }
                            
                            Image(systemName: "eye.fill").foregroundColor(accent).onTapGesture { viewModel.showPW.toggle() }
                        }
                        .padding()
                        .overlay(focusedField == FormFields.password ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top])
                    }

//                    .alert(isPresented: $viewModel.passwordNotComplex) {
//                        Alert(title: Text("Password must be between 8 and 16 characters and contain at least 1 number and 1 uppercase letter."))
//                    }
                    
                    if focusedField == .password && capLetterFound == false || pwNotValid {
                        HStack {
                            Text("1 Uppercase X").font(.caption2).foregroundColor(.red)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    }
                    
                    if focusedField == .password && numberFound == false || pwNotValid {
                        HStack {
                            Text("1 Number X").font(.caption2).foregroundColor(.red)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    }
                }
                
                // MARK: email
                HStack {
                    Text("@").foregroundColor(accent)
                    TextField("", text: $viewModel.email)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.email.isEmpty, placeHolder: "Email"))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .address
                        }
                }
                .padding()
                .overlay(focusedField == FormFields.email ? AnyView(activeField) : AnyView(nonActiveField))
                .padding()
                
                
                // MARK: Address
                   HStack {
                       Image(systemName: "signpost.right.fill").foregroundColor(accent)
                       TextField("Address", text: $mapSearch.searchTerm)
                        .onChange(of: mapSearch.searchTerm) { [oldAddyString = mapSearch.searchTerm] newStr in
                           // if the password is empty, reset the found flag
                           //if newStr.count < 1 {
                           //    mapSearch.locationResults = []
                           //    mapSearch.addressFound = false // this allows searches to be performed
                           //}
                               
                            // if the new string is shorter than the old one, we know they are deleting and therefore suggestions should show up
                            if newStr.count < oldAddyString.count {
                                mapSearch.addressFound = false
                            }
                       }
                   }
                   .focused($focusedField, equals: .address)
                   .padding()
                   .overlay(focusedField == FormFields.address ? AnyView(activeField) : AnyView(nonActiveField))
                   .padding()
                
                if !mapSearch.locationResults.isEmpty {
                   Section {
                       ScrollView {
                           ForEach(mapSearch.locationResults, id: \.self) { location in
                                   VStack(alignment: .leading) {
                                       Text(location.title)
                                           .font(.subheadline)
                                           .frame(maxWidth: .infinity, alignment: .center)
                                       Text(location.subtitle)
                                           .font(.system(.caption))
                                           .frame(maxWidth: .infinity, alignment: .center)
                                   }.onTapGesture {
                                       // when they select a location clear out the search results and then...
                                       mapSearch.addressFound = true
                                       mapSearch.locationResults = []
                                       mapSearch.searchTerm = "\(location.title) \(location.subtitle)"
                                       //viewModel.address = "\(location.title) \(location.subtitle)"
                                       
                                       mapSearch.validateAddress(location: location)
                                   }
                               Divider()
                           }
                       }
                       .frame(maxHeight: 120)
                   }
                   .overlay(suggestionsListOutline)
                   .padding(.horizontal, 3.0)
                }
                //Spacer()
                // MARK: Register Button
                Button("Register") {
                    guard viewModel.avatar != UIImage(named: "AddPhoto") else {
                        viewModel.avatarNotUploaded = true
                        return
                    }
                    // make sure all fields aren't empty
                    guard viewModel.textFieldsEmpty() == false else {
                        viewModel.fieldsEmpty = true
                        return
                    }
                    
                    guard viewModel.firstName.count > 1, viewModel.lastName.count > 1 else {
                        self.namesTooShort = true
                        focusedField = .fullName
                        return
                    }

                    guard
                        viewModel.password.count >= 8,
                        viewModel.password.count <= 16
                    else {
                        viewModel.passwordLengthIsInvalid = true
                        focusedField = .password
                        return
                    }

                    guard viewModel.pwContainsUppercase() else {
                        viewModel.passwordNotComplex = true
                        focusedField = .password
                        return
                    }

                    guard viewModel.pwContainsNumber() else {
                        viewModel.passwordNotComplex = true
                        focusedField = .password
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
                        focusedField = .username
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
                    
                    if mapSearch.addressInfo == nil { // we know that they didn't select an option from the list of suggestions
                        print("trying to find their addy via location string")
                        mapSearch.validateAddress(locationString: mapSearch.searchTerm) { (addressFound, addyInfo) in
                            print("their address was found")
                            guard let addressInfo = addyInfo else {
                                return
                            }
                            
                            //viewModel.getAndSaveUserLocation()
                            viewModel.registerUserV2(address: addressInfo.address, city: addressInfo.city, state: addressInfo.state, zipCode: addressInfo.zipCode, geolocation: addressInfo.geolocation)
                        }
                    } else { // I can force unwrap here because I know it doesn't equal nil
                        viewModel.registerUserV2(address: mapSearch.addressInfo!.address, city: mapSearch.addressInfo!.city, state: mapSearch.addressInfo!.state, zipCode: mapSearch.addressInfo!.zipCode, geolocation: mapSearch.addressInfo!.geolocation)
                        }
                }.alert(isPresented: $viewModel.dataPosted) {
                    Alert(title: Text("Success"), message: Text("You've now been signed up, go back and log in."), dismissButton: .default(Text("OK"), action: { dismiss() }))
                }
                
                //Spacer()
            }
            
        }.sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
            PhotoPicker(plantImage: $viewModel.avatar, plantImage2: Binding.constant(nil), plantImage3: Binding.constant(nil), plantEnum: $viewModel.imageEnum)
        }).navigationBarTitle(Text(""), displayMode: .inline)
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
