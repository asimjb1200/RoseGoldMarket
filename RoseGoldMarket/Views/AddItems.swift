//
//  AddItems.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI
import Combine

struct AddItems: View {
    @EnvironmentObject var user:UserModel
    @StateObject var viewModel: AddItemsViewModel = AddItemsViewModel()
    @FocusState var descriptionFieldIsFocus:Bool
    @FocusState var nameFieldIsFocus:Bool
    @Binding var tab: Int
    @State var profanityFound = false
    @State var tooManyChars = false
    @State var descriptionLengthInvalid = false
    @State var imagesMissing = false
    @State var categoriesMissing = false
    @State var descOffset: CGFloat = 0
    @State var useCamera = false
    @State var currentPhotoChoice: WhichPhoto = .image1
    @State var image1: UIImage?
    @State var image2: UIImage?
    @State var image3: UIImage?
    @State var typing = false
    
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    var submitButtonWidth = UIScreen.main.bounds.width * 0.70
    var leadingLabelPadding = UIScreen.main.bounds.width * 0.1
    var categoryMapper = CategoryMapper()
    let accent = Color(hue: 1.0, saturation: 0.03, brightness: 0.454)
    
    init(tab: Binding<Int>) {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UITextView.appearance().backgroundColor = .clear
        self._tab = tab // initialize a binding
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
                if descOffset == 0 {
                    Text("Tap to Add Photos")
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor"))
                        .padding([.leading, .top])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .alert(isPresented: $viewModel.errorOccurred) {
                            Alert(title: Text("There was a problem. Try again later."))
                        }
                }
                
                HStack {
                    ZStack {
                        if image1 == nil {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(.lightGray))
                                .shadow(radius: 25)
                            Circle()
                                .frame(width: 90, height: 90)
                                .foregroundColor(Color(.systemGray6))
                                .padding()
                                .shadow(radius: 25)
                        } else {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .shadow(radius: 25)
                            Image(uiImage: image1!)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 90, height: 90)
                        }
                    }.onTapGesture {
                        currentPhotoChoice = .image1
                        viewModel.isShowingPhotoPicker = true
                    }
                    
                    ZStack {
                        if image2 == nil {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(.lightGray))
                                .shadow(radius: 25)
                            Circle()
                                .frame(width: 90, height: 90)
                                .foregroundColor(Color(.systemGray6))
                                .padding()
                                .shadow(radius: 25)
                        } else {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .shadow(radius: 25)
                            Image(uiImage: image2!)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 90, height: 90)
                        }
                    }.onTapGesture {
                        currentPhotoChoice = .image2
                        viewModel.isShowingPhotoPicker = true
                    }
                    
                    ZStack {
                        if image3 == nil {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(.lightGray))
                                .shadow(radius: 25)
                            Circle()
                                .frame(width: 90, height: 90)
                                .foregroundColor(Color(.systemGray6))
                                .padding()
                                .shadow(radius: 25)
                        } else {
                            Circle() // outer rim
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .shadow(radius: 25)
                            Image(uiImage: image3!)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 90, height: 90)
                        }
                    }.onTapGesture {
                        currentPhotoChoice = .image3
                        viewModel.isShowingPhotoPicker = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: descOffset)
                .alert(isPresented: $imagesMissing) {
                    Alert(title: Text("Image Selection"), message: Text("Please upload 3 unique photos of your plant."), dismissButton: .default(Text("OK")))
                }
                
                // MARK: Name
                Group {
                    Text("Plant Name").fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.leading, leadingLabelPadding).frame(maxWidth: .infinity, alignment: .leading).padding(.top)
                    TextField("20 characters max..", text: $viewModel.plantName)
                        .padding()
                        .focused($nameFieldIsFocus)
                        .frame(width: buttonWidth)
                        .modifier(CustomTextBubble(isActive: nameFieldIsFocus == true, accentColor: .blue))
                        .shadow(radius: 5)
                        .onChange(of: viewModel.plantName) {
                            viewModel.plantName = String($0.prefix(20)) // limit 20 characters
                        }
                        .toolbar { // I guess setting it once sets the keyboard for the entire view
                            ToolbarItem(placement: .keyboard) {
                                Button("Done") {
                                    if nameFieldIsFocus {
                                        nameFieldIsFocus = false
                                    }
                                    if descriptionFieldIsFocus {
                                        descriptionFieldIsFocus = false
                                    }
                                }
                                .foregroundColor(Color("AccentColor"))
                                .frame(maxWidth:.infinity, alignment:.leading)
                            }
                        }
                }
                .offset(y: descOffset)
                .alert(isPresented: $tooManyChars) {
                    Alert(title: Text("Too Many Characters"), message: Text("Enter no more than 20 characters for Name."), dismissButton: .default(Text("OK")))
                }

                // MARK: Description
                Group {
                    Text("Description").fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.leading, leadingLabelPadding).frame(maxWidth: .infinity, alignment: .leading).padding(.top)
                    TextField("", text: $viewModel.plantDescription, axis: .vertical)
                        .focused($descriptionFieldIsFocus)
                        .lineLimit(5)
                        .padding()
                        .frame(width: buttonWidth)
                        .modifier(CustomTextBubble(isActive: descriptionFieldIsFocus == true, accentColor: .blue))
                        .shadow(radius: 5)
                        .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                            if descriptionFieldIsFocus == true {
                                // MARK: Keyboard Height Code
                                guard keyboardHeight > 0 else {
                                    withAnimation {
                                        descOffset = 0
                                    }
                                    return
                                }
                                
                                withAnimation {
                                    self.descOffset = 50 * -1
                                }
                            } else {
                                withAnimation {
                                    self.descOffset = 0
                                }
                            }
                        }
                        .onChange(of: viewModel.plantDescription) {
                            viewModel.plantDescription = String($0.prefix(200)) // limit to 200 characters
                        }
                }.offset(y: descOffset)
               
                Button(
                    action: {viewModel.isShowingCategoryPicker = true},
                    label: {
                        Text("Choose Categories")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentColor")).frame(width: buttonWidth, height: 50))
                            .offset(y: descOffset)
                            .sheet(isPresented: $viewModel.isShowingCategoryPicker) {
                                Text("Choose Your Categories")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("MainColor"))
                                    .padding([.top, .bottom])
                                
                                ForEach($viewModel.categoryHolder) { $cat in
                                    Toggle("\(categoryMapper.categories[cat.category]!)", isOn: $cat.isActive)
                                        .tint(Color("MainColor"))
                                        .padding([.leading, .trailing])
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                            .padding(.top)
                            .alert(isPresented: $categoriesMissing) {
                                Alert(title: Text("Missing Categories"), message: Text("Add categories to your plant."), dismissButton: .default(Text("OK!")))
                            }
                    }
                )
                
                Button(
                    action: {
                        guard plantImagesAdded() == true else {
                            imagesMissing = true
                            return
                        }
                        
                        guard !viewModel.plantName.isEmpty else {
                            nameFieldIsFocus = true
                            return
                        }
                        
                        guard !viewModel.plantDescription.isEmpty else {
                            descriptionFieldIsFocus = true
                            return
                        }
                        
                        guard viewModel.categoryChosen == true else {
                            categoriesMissing = true
                            return
                        }
                        
                        guard
                            viewModel.plantName.count <= 20
                        else {
                            nameFieldIsFocus = true
                            tooManyChars = true
                            return
                        }
                        
                        guard viewModel.plantDescription.count <= 200
                        else {
                            descriptionFieldIsFocus = true
                            descriptionLengthInvalid = true
                            return
                        }
                        
                        guard
                            let plantImage = image1?.jpegData(compressionQuality: 0.5),
                            let plantImage2 = image2?.jpegData(compressionQuality: 0.5),
                            let plantImage3 = image3?.jpegData(compressionQuality: 0.5)
                        else {
                            print("couldn't get the images and compress them")
                            return
                        }
                        
                        viewModel.savePlant(accountid: user.accountId, plantImage: plantImage, plantImage2: plantImage2, plantImage3: plantImage3, user: user)
                        
                        // reset everything now
                        viewModel.plantName = ""
                        viewModel.plantDescription = ""
                        descriptionFieldIsFocus = false
                        nameFieldIsFocus = false
                    },
                    label: {
                        Text("Submit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentColor")).frame(width: submitButtonWidth, height: 50))
                            .padding(.top)
                            .offset(y: descOffset)
                            .alert(isPresented: $viewModel.itemPosted) {
                                return Alert(title: Text("Success"), message: Text("Your plant is now live on the market!"), dismissButton: .default(Text("OK!"), action: {
                                    self.tab = 0
                                }))
                            }
                    }
                )
                Spacer()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarTitle(Text("New Plant Listing"), displayMode: .inline)
            .sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
                switch currentPhotoChoice {
                case .image1:
                    ImageSelector(image: $image1, canSelectMultipleImages: false, images: Binding.constant([]))
                case .image2:
                    ImageSelector(image: $image2, canSelectMultipleImages: false, images: Binding.constant([]))
                case .image3:
                    ImageSelector(image: $image3, canSelectMultipleImages: false, images: Binding.constant([]))
                }
                
            })
    }
    
    func plantImagesAdded() -> Bool {
        for plant in [image1, image2, image3] {
            guard plant != nil else {
                return false
            }
        }
        return true
    }
}

struct AddItems_Previews: PreviewProvider {
    static var previews: some View {
        AddItems(tab: Binding.constant(2))
//            .preferredColorScheme(.dark)
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(20)
    }
}


extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
