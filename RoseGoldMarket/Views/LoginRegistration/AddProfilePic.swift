//
//  AddProfilePic.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/20/22.
//

import SwiftUI
import Combine

struct AddProfilePic: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var registerViewModel: RegisterUserViewModel// using observed object bc this view doesn't own the data
    @State private var wave = false
    @FocusState var focusedField:FormFields?
    @State var charCount = 16
    @State var errorOccurred = false
    @State var mustAcceptTerms = false
    @Environment(\.dismiss) private var dismiss
    @State var newUsernamePublisher = PassthroughSubject<String, Never>()
    @State var debouncedText = ""
    @State var isAvailable = false
    @State var loading = false
    
    @State var acceptedTerms = false
    @EnvironmentObject var appViewState: CurrentAppView
    
    let userService = UserNetworking.shared
    let accent = Color.blue
    private let nonActiveField: some View = RoundedRectangle(cornerRadius: 30).stroke(.gray, lineWidth: 1)
    private let activeField: some View = RoundedRectangle(cornerRadius: 30).stroke(Color.blue, lineWidth:3)
    
    var body: some View {
        if registerViewModel.loading {
            ProgressView().tint(accent)
        } else {
            VStack {
                Text("Choose Your Name and Profile Picture")
                    .font(.title3)
                    .padding([.leading, .trailing])
                    .alert(isPresented: $errorOccurred) {
                        Alert(title: Text("An error occurred, try again later."))
                    }
                
                // MARK: Avatar
                ZStack {
                    Circle()
                        .frame(width: 160, height: 160)
                        .foregroundColor(accent)
                        .shadow(radius: 25)
                    if registerViewModel.avatar == nil {
                        Menu("Add a Photo") {
                            Button("Take Photo") {
                                registerViewModel.useCamera = true
                                registerViewModel.isShowingPhotoPicker.toggle()
                            }
                            Button("Choose From Library") {
                                registerViewModel.useCamera = false
                                registerViewModel.isShowingPhotoPicker.toggle()
                            }
                        }
                        .background(Circle().frame(width: 150, height: 150).foregroundColor(colorScheme == .light ? .white : .black))
                        .alert(isPresented: $registerViewModel.avatarNotUploaded) {
                            Alert(title: Text("Please upload an avatar"))
                        }
                    } else {
                        Image(uiImage: registerViewModel.avatar!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                            .shadow(radius: 25)
                            .onTapGesture {
                                registerViewModel.avatar = nil
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
                        .textContentType(.username)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                Button("Done") {
                                    focusedField = nil
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .onChange(of: registerViewModel.username) {
                            registerViewModel.username = String($0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(16))
                            newUsernamePublisher.send(registerViewModel.username)
                        }
                        .onReceive(newUsernamePublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { debouncedUsername in
                            debouncedText = debouncedUsername
                            if debouncedText.count > 5 {
                                checkAvailability(usernameToCheck: debouncedText.lowercased())
                            }
                        }
                        .onSubmit {
                            focusedField = nil
                        }
                }
                .padding()
                .modifier(CustomTextBubble(isActive: focusedField == FormFields.username, accentColor: accent))
                .padding([.leading, .trailing])
                .padding(.top)
                .alert(isPresented: $registerViewModel.nameNotAvailable) {
                    Alert(title: Text("That display name isn't available."))
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
                } else {
                    Text("6 or more characters")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                }
//                Text("Character Limit: \(charCount)")
//                    .fontWeight(.light)
//                    .font(.caption)
//                    .frame(maxWidth: .infinity,alignment:.leading)
//                    .padding(.leading)
//                    .foregroundColor(focusedField == FormFields.username ? accent : Color.gray)
//                    .alert(isPresented: $registerViewModel.usernameLengthIsInvalid) {
//                        Alert(title: Text("Display name must be between 5 and 16 characters."))
//                    }
                
                HStack(alignment: .top) {
                    Rectangle()
                        .fill(acceptedTerms ? .green : .clear)
                        .frame(width: 20, height: 20)
                        .border(.gray, width: 2)
                        .onTapGesture {
                            acceptedTerms.toggle()
                        }
                    
                    Text("Tap here to accept our [Terms and Conditions](https://www.rosegoldgardens.com/terms.html) of app usage.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .padding([.top, .leading])
                .alert(isPresented: $mustAcceptTerms) {
                    Alert(title: Text("To use this Service you must accept the Terms and Conditions of usage"), message: Text("We've made this mandatory to ensure a safe and subject matter focused marketplace for all users. This is also to try and make an effort to keep the application free of content that is obscene and/or offensive."))
                }
                
                Text("Review our [Privacy Policy](https://www.rosegoldgardens.com/privacy.html).")
                    .padding(.top, 50)
                    .foregroundColor(.gray)
                    .alert(isPresented: $registerViewModel.emailTaken) {
                        Alert(title: Text("That email address is already in use"))
                    }
                
                
                Button("Confirm Account") {
                    guard registerViewModel.dataPosted == false else {
                        return
                    }
                    
                    guard registerViewModel.avatar != nil else {
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
                    
                    guard
                        acceptedTerms == true
                    else {
                        mustAcceptTerms.toggle()
                        return
                    }
                    
                    guard isAvailable else { return }
                    
                    let sanitizedPhone = registerViewModel.phone.replacingOccurrences(of: "-", with: "")
                    
                    registerViewModel.loading = true
                    registerViewModel.registerUserV2(address: addyInfo.address, phone: sanitizedPhone, city: addyInfo.city, state: addyInfo.state, zipCode: addyInfo.zipCode, geolocation: addyInfo.geolocation)
                    
                }
                .foregroundColor(Color.white)
                .font(.system(size: 16, weight: Font.Weight.bold))
                .padding()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: 190))
                .padding(.top, 100.0)
                .alert(isPresented: $registerViewModel.dataPosted) {
                    Alert(title: Text("Verify Account"), message: Text("You've completed the first registration step. Go to your email and check for a message from us (support@rosegoldgardens.com) to complete the verification process. Make sure to check your spam/junk folders if you don't see it."), dismissButton: .default(Text("Log In")) {
                        registerViewModel.canLoginNow = true
                        //dismiss()
                        withAnimation {
                            appViewState.currentView = .LoginView
                        }
                    })
                }.shadow(radius: 5)
                
                Spacer()
            }
            .tint(accent)
            .sheet(isPresented: $registerViewModel.isShowingPhotoPicker) {
                if registerViewModel.useCamera {
                    CameraAccessor(selectedImage: $registerViewModel.avatar)
                } else {
                    ImageSelector(image: $registerViewModel.avatar, canSelectMultipleImages: false, images: Binding.constant([]))
                }
            }
        }
    }
    
    func checkAvailability(usernameToCheck: String) {
        self.loading = true
        userService.checkUsernameAvailability(newUsername: debouncedText) { isAvailableResponse in
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
}

struct AddProfilePic_Previews: PreviewProvider {
    static var previews: some View {
        AddProfilePic(registerViewModel: RegisterUserViewModel())
            .preferredColorScheme(.dark)
            
    }
}
