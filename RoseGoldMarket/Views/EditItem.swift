//
//  EditItem.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/4/22.
//

import SwiftUI
import Combine // for access to the publisher

struct EditItem: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var user:UserModel
    @StateObject var viewModel = EditItemVM()
    @FocusState var focusedField:EditFields?
    @State var descOffset: CGFloat = 0
    @State var typing = false
    @State var areYouSure = false
    @State var currentPhotoChoice: WhichPhoto = .image1
    @State var image1: UIImage?
    @State var image2: UIImage?
    @State var image3: UIImage?
    @State var typingDesc = false
    
    @State var buttonHeight:CGFloat = 30
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var categoryMapper = CategoryMapper()
    let itemName:String
    let ownerName:String
    let itemId:UInt
    
    var body: some View {
        VStack(alignment: .leading) {
            if !typingDesc {
                Text("Tap to change your photos")
                    .foregroundColor(Color("AccentColor"))
                    .padding([.leading, .top])
            }
            
            // MARK: Plant Photos
            HStack {
                ZStack {
                    Circle() // outer rim
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(.lightGray))
                        .shadow(radius: 25)
                        .task {
                            getImage(owner: ownerName, itemName: itemName, imageNumber: 1)
                        }
                    
                    if image1 != nil {
                        Image(uiImage: image1!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 90, height: 90)
                    } else {
                        Circle()
                            .frame(width: 90, height: 90)
                            .foregroundColor(Color(.systemGray6))
                            .padding()
                            .shadow(radius: 25)
                    }
                }
                .onTapGesture {
                    currentPhotoChoice = .image1
                    viewModel.isShowingPhotoPicker = true
                }
                
                ZStack {
                    Circle() // outer rim
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(.lightGray))
                        .shadow(radius: 25)
                        .task {
                            getImage(owner: ownerName, itemName: itemName, imageNumber: 2)
                        }
                    
                    if image2 != nil {
                        Image(uiImage: image2!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 90, height: 90)
                    } else {
                        Circle()
                            .frame(width: 90, height: 90)
                            .foregroundColor(Color(.systemGray6))
                            .padding()
                            .shadow(radius: 25)
                    }
                }
                .onTapGesture {
                    currentPhotoChoice = .image2
                    viewModel.isShowingPhotoPicker = true
                }
                
                ZStack {
                    Circle() // outer rim
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(.lightGray))
                        .shadow(radius: 25)
                        .task {
                            getImage(owner: ownerName, itemName: itemName, imageNumber: 3)
                        }
                    
                    if image3 != nil {
                        Image(uiImage: image3!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 90, height: 90)
                    } else {
                        Circle()
                            .frame(width: 90, height: 90)
                            .foregroundColor(Color(.systemGray6))
                            .padding()
                            .shadow(radius: 25)
                    }
                }
                .onTapGesture {
                    currentPhotoChoice = .image3
                    viewModel.isShowingPhotoPicker = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
            .alert(isPresented: $viewModel.addPhotos) {
                Alert(title:Text("Plant Photos"), message: Text("Add 3 unique photos of your plant"))
            }.offset(y: descOffset * -1)
            
            // MARK: Plant Name
            Group {
                Text("Name:").foregroundColor(Color("AccentColor")).padding(.leading)
                TextField("", text: $viewModel.plantName)
                    .padding()
                    .focused($focusedField, equals: .name)
                    .modifier(CustomTextBubble(isActive: focusedField == EditFields.name, accentColor: .blue))
                    .padding([.leading, .trailing])
                    .shadow(radius: 5)
                    .onChange(of: viewModel.plantName) {
                        viewModel.plantName = String($0.prefix(20)) // limit to 20 characters
                    }
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                focusedField = nil
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .onSubmit {
                        focusedField = .description
                    }
                    .onAppear(){
                        viewModel.getItemData(itemId: itemId, user: user)
                    }
            }
            .alert(isPresented: $viewModel.tooManyChars) {
                Alert(title: Text("Too Many Characters"), message: Text("Enter no more than 20 characters for Name."), dismissButton: .default(Text("OK")))
            }.offset(y: descOffset * -1)
            
            // MARK: Description
            Group {
                Text("Description:")
                    .foregroundColor(Color("AccentColor"))
                    .padding([.leading, .top])
                    .alert(isPresented: $viewModel.tooManyChars) {
                        Alert(title: Text("Too Many Characters"), message: Text("Name field can have no more than 20 characters. The description field can have no more than 200."))
                    }
                
                TextField("", text: $viewModel.plantDescription, axis: .vertical)
                    .lineLimit(5)
                    .focused($focusedField, equals: EditFields.description)
                    .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                        if focusedField == .description {
                            // MARK: Keyboard Height Code
                            guard keyboardHeight > 0 else {
                                withAnimation {
                                    typingDesc = false
                                    descOffset = 0
                                    buttonHeight = 30
                                }
                                return
                            }
                            
                            //let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                            
                            //let screen = UIScreen.main.bounds
                            //let topOfKeyboard = screen.size.height - keyboardHeight
                            //let moveUpThisMuch = focusedTextInputBottom - topOfKeyboard + 20

                            withAnimation {
                                typingDesc = true
                                self.descOffset = 50
                                buttonHeight = 0
                            }
                        } else {
                            withAnimation {
                                typingDesc = false
                                descOffset = 0
                                buttonHeight = 30
                            }
                        }
                    }
                    .padding()
                    .modifier(CustomTextBubble(isActive: focusedField == EditFields.description, accentColor: .blue))
                    .padding([.leading, .trailing, .bottom])
                    .shadow(radius: 5)
                    .onChange(of: viewModel.plantDescription) {
                        viewModel.plantDescription = String($0.prefix(200)) // limit to 200 characters
                    }
                    .onSubmit {
                        focusedField = nil
                    }
            }.offset(y: descOffset * -1)
            
            Toggle("Still available?", isOn: $viewModel.isAvailable)
                .padding([.leading, .bottom, .trailing])
                .tint(Color("MainColor"))
                .offset(y: descOffset)
                .alert(isPresented: $viewModel.itemIsDeleted) {
                    Alert(title: Text("Success"), message: Text("Your item has been deleted"), dismissButton: .default(Text("OK"), action: { dismiss() }))
                }
            
            if !viewModel.isAvailable {
                Toggle("Has it been picked up?", isOn: $viewModel.pickedUp).padding([.leading, .bottom, .trailing]).tint(Color("MainColor"))
            }
            

            // MARK: Choose categories
            Button(
                action: {
                    viewModel.isShowingCategoryPicker = true
                },
                label: {
                    Text("Choose Categories")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: buttonHeight, alignment: .center)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentColor")).frame(width: buttonWidth, height: buttonHeight))
                        .padding(.top)
                }
            )
            .onAppear() {
                if viewModel.firstAppear {
                    viewModel.firstAppear = false
                    CategoryIds.allCases.forEach {
                        // create a category object for each of the categories ids
                        viewModel.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
                    }
                }
            }
            .alert(isPresented: $viewModel.missingCategories) {
                Alert(title: Text("Missing Categories"), message: Text("Make sure to pick some categories for your plant"), dismissButton: .default(Text("OK")))
            }
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
            .offset(y: descOffset)
            
            // MARK: Update Button
            Button(
                action:{
                    // figure out if the images have been changed etc
                    guard plantImagesAdded() else {
                        viewModel.addPhotos = true
                        return
                    }
                    guard !viewModel.plantName.isEmpty else {
                        focusedField = .name
                        return
                    }
                    guard !viewModel.plantDescription.isEmpty else {
                        focusedField = .description
                        return
                    }
                    guard viewModel.categoryChosen == true else {
                        viewModel.missingCategories = true
                        return
                    }
                    
                    guard
                        viewModel.plantDescription.count <= 200
                    else {
                        focusedField = .description
                        viewModel.tooManyChars = true
                        return
                    }
                    
                    guard viewModel.plantName.count <= 20 else {
                        focusedField = .name
                        return
                    }
                    
                    guard
                        let plantImage = image1?.jpegData(compressionQuality: 0.5),
                        let plantImage2 = image2?.jpegData(compressionQuality: 0.5),
                        let plantImage3 = image3?.jpegData(compressionQuality: 0.5)
                    else {
                        return
                    }
                    
                    viewModel.savePlant(accountid: user.accountId, plantImage: plantImage, plantImage2: plantImage2, plantImage3: plantImage3, itemId: itemId, user:user)
                },
                label: {
                    Text("Update")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: buttonHeight, alignment: .center)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentColor")).frame(width: buttonWidth, height: buttonHeight))
                    
                }
            )
            .sheet(isPresented: $viewModel.isShowingPhotoPicker){
                switch currentPhotoChoice {
                case .image1:
                    ImageSelector(image: $image1, canSelectMultipleImages: false, images: Binding.constant([]))
                case .image2:
                    ImageSelector(image: $image2, canSelectMultipleImages: false, images: Binding.constant([]))
                case .image3:
                    ImageSelector(image: $image3, canSelectMultipleImages: false, images: Binding.constant([]))
                }
            }
            .offset(y: descOffset)
            
            Button(
                action: { areYouSure = true },
                label: {
                    Text("Delete")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: buttonHeight, alignment: .center)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.red).frame(width: buttonWidth, height: buttonHeight))
                }
            )
            .alert(isPresented: $areYouSure) {
                Alert(
                    title: Text("Are You Sure?"),
                    message: Text("You're about to delete your item. You can't undo this."),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteItem(itemId: itemId, user:user)
                    },
                    secondaryButton: .cancel()
                )
            }
            
            Spacer()
        }.ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension EditItem {
    func getImage(owner: String, itemName: String, plantID: UUID) {
        let itemNameWithoutSpaces: String = itemName.replacingOccurrences(of: " ", with: "%20")
        let imageIndex: Int? = viewModel.plantImages.firstIndex { $0.id == plantID }
        guard let imageIndex = imageIndex else {
            print("that image doesnt exist")
            return
        }
        let imageNumber = imageIndex + 1
        
        // for each plant the images are stored as "image1", "image2", "image3"
        if let url: URL = URL(string: "https://rosegoldgardens.com/api/images/\(ownerName)/\(itemNameWithoutSpaces)/image\(imageNumber).jpg") {
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard err == nil else {
                    print("an error occurred")
                    return
                }
                
                guard let imageData: Data = data else {
                    print("couldnt decode data")
                    return
                }
                
                DispatchQueue.main.async {
                    viewModel.plantImages[imageIndex] = PlantImage(id: UUID(), image: UIImage(data: imageData))
                }
            }.resume()
        }
    }
    
    func getImage(owner: String, itemName: String, imageNumber: Int) {
        let itemNameWithoutSpaces: String = itemName.replacingOccurrences(of: " ", with: "%20")
        
        // for each plant the images are stored as "image1", "image2", "image3"
        if let url: URL = URL(string: "https://rosegoldgardens.com/api/images/\(ownerName)/\(itemNameWithoutSpaces)/image\(imageNumber).jpg") {
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard err == nil else {
                    print("an error occurred")
                    return
                }
                
                guard let imageData: Data = data else {
                    print("couldnt decode data")
                    return
                }
                
                DispatchQueue.main.async {
                    if imageNumber == 1 {
                        self.image1 = UIImage(data: imageData)
                    } else if imageNumber == 2 {
                        self.image2 = UIImage(data: imageData)
                    } else if imageNumber == 3 {
                        self.image3 = UIImage(data: imageData)
                    }
                }
            }.resume()
        }
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

struct EditItem_Previews: PreviewProvider {
    static var previews: some View {
        EditItem(itemName: "Shrubs", ownerName: "dee", itemId: 25)
    }
}
