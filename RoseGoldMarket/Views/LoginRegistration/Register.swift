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
    @State private var wave = false
    @FocusState private var focusedField:FormFields?
    @State private var capLetterFound = false
    @State private var numberFound = false

    private let defaultImage = UIImage(systemName: "plus.circle.fill")!.withTintColor(.white, renderingMode: .alwaysTemplate)
    private let dividerView: some View = Divider().frame(height: 5).background(Color("AccentColor"))
    private let gradientBG: some View = RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [.white, Color("MainColor")]), startPoint: .leading, endPoint: .trailing))
    private enum FormFields: Int, CaseIterable {
        case firstName, lastName, username, address, password, email, city, zipcode, state
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
                    Text("Add Profile Picture")
                        .font(.caption)
                    ZStack {
                        // now let's perform checks to only pulsate if the default image is up
                        if viewModel.avatar == defaultImage {
                            Circle()
                                .stroke(lineWidth: 40)
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color("AccentColor"))
                                .scaleEffect(wave ? 1 : 0.5)
                               .opacity(wave ? 0.1 : 1)
                                .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(0.5))
                                .onAppear() {
                                    self.wave.toggle()
                                }
                            
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(accent)
                                .shadow(radius: 25)
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
                
                // first and last name
                Group {
                    TextField("", text: $viewModel.firstName)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.firstName.isEmpty, placeHolder: "First Name..."))
                        .padding()
                        .background(gradientBG)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .firstName)
                        .padding()
                        .onSubmit {
                            focusedField = .lastName
                        }
                    
                    
                    TextField("", text: $viewModel.lastName)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.lastName.isEmpty, placeHolder: "Last Name..."))
                        .padding()
                        .background(gradientBG)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .lastName)
                        .padding([.leading, .trailing, .bottom])
                        .onSubmit {
                            focusedField = .username
                        }
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
                            .onSubmit {
                                focusedField = .password
                            }
                    }
                    .padding()
                    .background(gradientBG)
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
                                .modifier(PlaceholderStyle(showPlaceHolder: viewModel.password.isEmpty, placeHolder: "Password..."))
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .email
                                }
                            
                            Image(systemName: "eye").foregroundColor(accent).onTapGesture { viewModel.showPW.toggle() }
                        }
                        .padding()
                        .background(gradientBG)
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
                        .background(gradientBG)
                        .padding([.leading, .trailing, .top])
                    }

//                    .alert(isPresented: $viewModel.passwordNotComplex) {
//                        Alert(title: Text("Password must be between 8 and 16 characters and contain at least 1 number and 1 uppercase letter."))
//                    }
                    
                    HStack {
                        Text(capLetterFound ? "1 Uppercase √" : "1 Uppercase X").font(.caption2).foregroundColor(capLetterFound == true ? .green : .red)
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    
                    HStack {
                        Text(numberFound ? "1 Number √" : "1 Number X").font(.caption2).foregroundColor(numberFound == true ? .green : .red)
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    
                    
                    Text("Character Limit: \(charCount)")
                        .fontWeight(.light)
                        .font(.caption)
                        .frame(maxWidth: .infinity,alignment:.leading)
                        .padding(.leading)
                        .foregroundColor(accent)
                        .alert(isPresented: $viewModel.passwordLengthIsInvalid) {
                            Alert(title: Text("Password must be between 8 and 16 characters."))
                        }
                }
                
                // email
                HStack {
                    Text("@").foregroundColor(accent)
                    TextField("", text: $viewModel.email)
                        .modifier(PlaceholderStyle(showPlaceHolder: viewModel.email.isEmpty, placeHolder: "Email..."))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .address
                        }
                }
                .padding()
                .background(gradientBG)
                .padding()
                
                // address
                Group {
                    HStack {
                        Image(systemName: "signpost.right.fill").foregroundColor(accent)
                        TextField("", text: $viewModel.address)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.address.isEmpty, placeHolder: "Address..."))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .address)
                            .onSubmit {
                                focusedField = .city
                            }
                    }
                    .padding()
                    .background(gradientBG)
                    .padding()
                    
                    // city
                    HStack {
                        Image(systemName: "building.2.fill").foregroundColor(accent)
                        TextField("", text: $viewModel.city)
                            .modifier(PlaceholderStyle(showPlaceHolder: viewModel.city.isEmpty, placeHolder: "City..."))
                            .focused($focusedField, equals: .city)
                            .onSubmit {
                                focusedField = .state
                            }
                    }
                    .padding()
                    .background(gradientBG)
                    .padding()
                    
                    // state
                    HStack {
                        Image(systemName: "map.fill").foregroundColor(accent)
                        Picker("State", selection: $viewModel.state) {
                            ForEach(viewModel.statePicker, id:\.self) {
                                Text($0)
                            }
                        }.focused($focusedField, equals: .state)
                            .onSubmit {
                                focusedField = .zipcode
                            }
                        Spacer()
                    }
                    .frame(maxWidth:.infinity)
                    .padding()
                    .background(gradientBG)
                    .padding()
                    .alert(isPresented: $viewModel.addressIsFake) {
                        Alert(title: Text("Your address could not be verified."))
                    }
                    
                    // zip code
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
                    .background(gradientBG)
                    .padding().keyboardType(.decimalPad)
                }
                
                Button("Register") {
                    guard viewModel.avatar != UIImage(systemName: "plus.circle.fill") else {
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
