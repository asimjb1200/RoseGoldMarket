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
import UIKit


struct Register: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel:RegisterUserViewModel = RegisterUserViewModel()
    @State var specialCharFound = false
    @FocusState private var focusedField:FormFields?
    @State private var capLetterFound = false
    @State private var numberFound = false
    @State private var pwNotValid = false
    @State private var namesTooShort = false
    @StateObject private var mapSearch = MapSearch()
    @State private var oldAddyString = ""
    @State private var confirmPassword = ""
    @State private var activateLink = false
    @State private var pwDontMatch = false
    @State private var pwPadding:CGFloat = 0
    @State private var keyboardWillShow = false

    private let nonActiveField: some View = RoundedRectangle(cornerRadius: 30).stroke(.gray, lineWidth: 1)
    private let activeField: some View = RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth:3)
    private let suggestionsListOutline: some View = RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1)

    private let defaultImage = UIImage(named: "AddPhoto")!
    private let dividerView: some View = Divider().frame(height: 5).background(Color("AccentColor"))
    private let gradientBG: some View = RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [.white, Color("MainColor")]), startPoint: .leading, endPoint: .trailing))

    var charCount = 16
    var inputChecker:InputChecker = .shared
    let gradient = LinearGradient(gradient: Gradient(colors: [.white,  Color("MainColor")]), startPoint: .leading, endPoint: .trailing)
    let accent = Color.blue
    
    var body: some View {
        VStack(spacing: 0.0) {
            ScrollView {
                if self.pwPadding == 0 {
                    Group {
                        Text("Let's Get Started!")
                            .font(.title2)
                            .fontWeight(.bold)
                            
                        Text("Create a Rose Gold account to access the market.")
                            .font(.caption)
                    }
                }
                
                // MARK: first and last name
                HStack(spacing: 0.0) {
                    Image(systemName: "person.circle.fill").foregroundColor((focusedField == FormFields.firstName || focusedField == FormFields.lastName) ? accent : Color.gray)
                    TextField(" First Name", text: $viewModel.firstName)
                        .foregroundColor(Color.blue)
                        .focused($focusedField, equals: FormFields.firstName)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("Done") {
                                    focusedField = nil
                                }.foregroundColor(accent)
                                Spacer()
                            }
                        }
                        .onSubmit {
                            focusedField = FormFields.lastName
                        }
                    
                    TextField("Last Name", text: $viewModel.lastName)
                        .foregroundColor(Color.blue)
                        .focused($focusedField, equals: FormFields.lastName)
                        .onSubmit {
                            focusedField = FormFields.email
                        }
                }
                .padding()
                .background((focusedField == FormFields.firstName || focusedField == FormFields.lastName) ? AnyView(activeField) : AnyView(nonActiveField))
                .padding([.leading, .trailing, .top])
                .offset(y: self.pwPadding * -1)
                .alert(isPresented: $namesTooShort) {
                    Alert(title: Text("Names Too Short"), message: Text("Your first and last names must be at least 2 characters each."))
                }
                
                // MARK: email
                HStack(spacing: 0.0) {
                    Text("@ ").foregroundColor(focusedField == FormFields.email ? accent : Color.gray)
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .foregroundColor(Color.blue)
                        .onSubmit {
                            focusedField = .phone
                        }
                }
                .padding()
                .background(focusedField == FormFields.email ? AnyView(activeField) : AnyView(nonActiveField))
                .padding([.leading, .trailing, .top])
                .offset(y: self.pwPadding * -1)
                
                // MARK: Phone
                HStack(spacing: 0.0) {
                    Image(systemName: "phone.fill").foregroundColor(focusedField == FormFields.phone ? accent : Color.gray)
                    TextField(" Phone", text: $viewModel.phone)
                        .foregroundColor(Color.blue)
                        .focused($focusedField, equals: .phone)
                        .keyboardType(.numberPad)
                        .onSubmit {
                            focusedField = .address
                        }
                }
                .padding()
                .background(focusedField == FormFields.phone ? AnyView(activeField) : AnyView(nonActiveField))
                .padding([.leading, .trailing, .top])
                .offset(y: self.pwPadding * -1)
                
                // MARK: Address
                HStack(spacing: 0.0) {
                   Image(systemName: "signpost.right.fill").foregroundColor(focusedField == FormFields.address ? accent : Color.gray)
                   TextField(" Address", text: $mapSearch.searchTerm)
                    .foregroundColor(Color.blue)
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
                    .onSubmit {
                        mapSearch.locationResults = []
                        focusedField = .password
                    }
               }
               .focused($focusedField, equals: .address)
               .padding()
               .background(focusedField == FormFields.address ? AnyView(activeField) : AnyView(nonActiveField))
               .padding([.leading, .trailing, .top])
               .offset(y: self.pwPadding * -1)
               .alert(isPresented: $viewModel.addyNotFound) {
                   Alert(title: Text("Address Not Found"), message: Text("Please try again."))
               }
                
                if !mapSearch.locationResults.isEmpty {
                   Section {
                       ScrollView {
                           ForEach(mapSearch.locationResults, id: \.self) { location in
                               VStack(alignment: .leading, spacing: 0.0) {
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
                                       focusedField = .password
                                   }
                               Divider()
                           }
                       }
                       .frame(maxHeight: 120)
                   }
                   .overlay(suggestionsListOutline)
                   .padding(.horizontal, 3.0)
                }
                
                // MARK: password
                Group {
                    if viewModel.showPW == false {
                        HStack(spacing: 0.0) {
                            Image(systemName: "key.fill").foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                            SecureField(" Password", text: $viewModel.password)
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
                                .textInputAutocapitalization(.never)
                                .foregroundColor(Color.blue)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }

                            Image(systemName: "eye")
                                .foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                                .onTapGesture {
                                    viewModel.showPW.toggle()
                                    focusedField = FormFields.password
                                }
                        }
                        .padding()
                        .background(focusedField == FormFields.password ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top], 15.0)
                        
                    } else {
                        HStack(spacing: 0.0) {
                            Image(systemName: "key.fill").foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                            TextField(" Password", text: $viewModel.password)
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
                                .textInputAutocapitalization(.never)
                                .foregroundColor(Color.blue)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .password)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                            
                            Image(systemName: "eye.fill")
                                .foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                                .onTapGesture {
                                    viewModel.showPW.toggle()
                                    focusedField = FormFields.password
                                }
                        }
                        .padding()
                        .background(focusedField == FormFields.password ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top])
                    }

                    if viewModel.pwNeedsCaps {
                        HStack(spacing: 0.0) {
                            Text("1 Uppercase X").font(.caption2).foregroundColor(.red)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    }

                    if viewModel.pwNeedsNumbers {
                        HStack(spacing: 0.0) {
                            Text("1 Number X").font(.caption2).foregroundColor(.red)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    }
                }
                .offset(y: self.pwPadding * -1)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    if keyboardHeight > 0 && keyboardWillShow == false {
                        keyboardWillShow = true
                    } else {
                        keyboardWillShow = false
                    }
                    
                    var focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    
                    if focusedTextInputBottom > 0 {
                        focusedTextInputBottom += 15 // have to add in the padding so it scrolls outside of the text bubble styling
                    }
                    
                    let screen = UIScreen.main.bounds
                    let topOfKeyboard = screen.size.height - keyboardHeight
                    let moveUpThisMuch = focusedTextInputBottom - topOfKeyboard
                    if moveUpThisMuch > 0 && keyboardWillShow == true {
                        withAnimation(.linear) {
                            self.pwPadding = moveUpThisMuch
                        }
                        
                    }
                    
                    if keyboardHeight == 0 {
                        withAnimation(.linear) {
                            self.pwPadding = 0
                        }
                    }
                }
                .alert(isPresented: $viewModel.passwordLengthIsInvalid) {
                    Alert(title: Text("Password must be between 8 & 16 characters"))
                }
                
                // MARK: confirm password
                Group {
                    if viewModel.showConfPW == false {
                        HStack(spacing: 0.0) {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(Color.blue)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .confirmPassword)

                            Image(systemName: "eye")
                                .foregroundColor(focusedField == FormFields.confirmPassword ? accent : Color.gray)
                                .onTapGesture {
                                    viewModel.showConfPW.toggle()
                                    focusedField = FormFields.confirmPassword
                                }
                        }
                        .padding()
                        .background(focusedField == FormFields.confirmPassword ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top])
                        .alert(isPresented: $pwDontMatch) {
                            Alert(title: Text("Passwords Don't Match"))
                        }
                        .id(5)
                    } else {
                        HStack(spacing: 0.0) {
                            TextField("Confirm Password", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(Color.blue)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .confirmPassword)

                            Image(systemName: "eye.fill")
                                .foregroundColor(focusedField == FormFields.password ? accent : Color.gray)
                                .onTapGesture {
                                    viewModel.showConfPW.toggle()
                                    focusedField = FormFields.confirmPassword
                                }
                        }
                        .padding()
                        .background(focusedField == FormFields.confirmPassword ? AnyView(activeField) : AnyView(nonActiveField))
                        .padding([.leading, .trailing, .top])
                        .alert(isPresented: $pwDontMatch) {
                            Alert(title: Text("Passwords Don't Match"))
                        }
                    }
                }
                .offset(y: self.pwPadding * -1)
                
                // MARK: Register Button
                NavigationLink(destination: AddProfilePic(registerViewModel: viewModel), isActive: $activateLink) {
                    Button("CONTINUE") {
                        guard
                            viewModel.firstName.count > 1,
                            viewModel.lastName.count > 1
                        else {
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
                        
                        
                        let containsNums = viewModel.pwContainsNumber()
                        let containsUppers = viewModel.pwContainsUppercase()
                        
                        guard
                            containsNums == true,
                            containsUppers == true
                        else {
                            if !containsUppers {
                                viewModel.pwNeedsCaps = true
                            } else {
                                viewModel.pwNeedsCaps = false
                            }
                            if !containsNums {
                                viewModel.pwNeedsNumbers = true
                            } else {
                                viewModel.pwNeedsNumbers = false
                            }
                            //focusedField = .password
                            return
                        }
                        
                        guard
                            viewModel.password == confirmPassword
                        else {
                            self.pwDontMatch = true
                            focusedField = .password
                            return
                        }

                        guard
                            mapSearch.searchTerm.count > 0
                        else {
                            focusedField = .address
                            return
                        }
                        
                        guard
                            viewModel.password.count > 0
                        else {
                            focusedField = .phone
                            return
                        }

                        if mapSearch.addressInfo == nil { // we know that they didn't select an option from the list of suggestions
                            mapSearch.validateAddress(locationString: mapSearch.searchTerm) { (addressFound, addyInfo) in
                                guard
                                    addressFound == true,
                                    let addressInfo = addyInfo else {
                                    viewModel.addyNotFound = true
                                    focusedField = .address
                                    return
                                }

                                viewModel.addressInfo = addressInfo

                                activateLink = true
                            }
                        } else { // I can force unwrap here because I know it doesn't equal nil
                            viewModel.addressInfo = mapSearch.addressInfo
                            activateLink = true
                        }
                    }
                    .foregroundColor(Color.white)
                    .font(.system(size: 16, weight: Font.Weight.bold))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
                    .padding(.top)
                    .alert(isPresented: $viewModel.dataPosted) {
                        Alert(title: Text("Success"), message: Text("You've now been signed up, go back and log in."), dismissButton: .default(Text("OK"), action: { dismiss() }))
                    }
                }

                HStack(spacing: 0.0) {
                    Text("Already have an account? ")
                    Button("Login Here") {
                        dismiss() // navigate back to the login screen
                    }.foregroundColor(Color.blue)
                }.padding(.top, 15.0)
            }
        }
        .sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
            PhotoPicker(plantImage: $viewModel.avatar, plantImage2: Binding.constant(nil), plantImage3: Binding.constant(nil), plantEnum: $viewModel.imageEnum)
        })
        .navigationBarTitle(Text(""), displayMode: .inline)
        .accentColor(Color.blue)
        .onAppear() {
            print("view model data posted prop: \(viewModel.canLoginNow)")
            if viewModel.canLoginNow {
                dismiss() // send them to the login screen because they've already signed up
            }
        }
    }
}



struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
