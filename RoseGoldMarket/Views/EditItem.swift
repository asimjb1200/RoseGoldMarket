//
//  EditItem.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/4/22.
//

import SwiftUI
import Combine // for access to the publisher
import _PhotosUI_SwiftUI

struct EditItem: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var user:UserModel
    @StateObject var viewModel = EditItemVM()
    @FocusState var focusedField:EditFields?
    @State var typing = false
    @State var areYouSure = false
    
    @State var typingDesc = false
    @State var firstAppear = true
    
    @State private var plantImages: [UIImage?] = [nil, nil, nil]
    @State private var selectedPlantImages: [PhotosPickerItem?] = [nil, nil, nil]
    
    @State var buttonHeight:CGFloat = 50
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var categoryMapper = CategoryMapper()
    var leadingLabelPadding = UIScreen.main.bounds.width * 0.1
    let itemName:String
    let ownerName:String
    let itemId:UInt
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            // MARK: Plant Photos
            LazyHStack {
                ForEach(selectedPlantImages.indices, id: \.self) { selectedImageIndex in
                    PhotosPicker(selection: $selectedPlantImages[selectedImageIndex], matching: .images) {
                        ZStack {
                            if let plantImage = plantImages[selectedImageIndex] {
                                Circle() // outer rim
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(Color(.lightGray))
                                
                                Image(uiImage: plantImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 90, height: 90)
                            } else {
                                ProgressView().tint(Color("AccentColor"))
                            }
                        }.onChange(of: selectedPlantImages[selectedImageIndex]) { _ in
                            Task {
                                if let data = try? await selectedPlantImages[selectedImageIndex]?.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        plantImages[selectedImageIndex] = uiImage
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .alert(isPresented: $viewModel.addPhotos) {
                Alert(title:Text("Plant Photos"), message: Text("Add 3 unique photos of your plant"))
            }
            
            // MARK: Plant Name
            Group {
                Text("Name").foregroundColor(Color("AccentColor"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .alert(isPresented: $viewModel.itemIsDeleted) {
                        Alert(title: Text("Success"), message: Text("Your item has been deleted"), dismissButton: .default(Text("OK"), action: { dismiss() }))
                    }
                
                TextField("", text: $viewModel.plantName)
                    .padding()
                    .focused($focusedField, equals: .name)
                    .modifier(CustomTextBubble(isActive: focusedField == EditFields.name, accentColor: .blue))
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
                    .alert(isPresented: $viewModel.plantUpdated) {
                        Alert(title: Text("Success"), message: Text("Your plant was updated"), dismissButton: .default(Text("OK")) { dismiss() })
                    }
            }
            .onAppear() {
                if firstAppear {
                    firstAppear = false
                    viewModel.getItemData(itemId: itemId, user: user)
                    CategoryIds.allCases.forEach {
                        // create a category object for each of the categories ids
                        viewModel.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
                    }
                    for num in 1...3 {
                        getImage(owner: ownerName, itemName: itemName, imageNumber: num)
                    }
                }
            }
            
            // MARK: Description
            Group {
                Text("Description")
                    .foregroundColor(Color("AccentColor"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .alert(isPresented: $viewModel.tooManyChars) {
                        Alert(title: Text("Too Many Characters"), message: Text("Name field can have no more than 20 characters. The description field can have no more than 200."))
                    }
                
                TextField("", text: $viewModel.plantDescription, axis: .vertical)
                    .focused($focusedField, equals: EditFields.description)
                    .padding()
                    .modifier(CustomTextBubble(isActive: focusedField == EditFields.description, accentColor: .blue))
                    .frame(minHeight: 50)
                    .shadow(radius: 5)
                    .onChange(of: viewModel.plantDescription) {
                        viewModel.plantDescription = String($0.prefix(200)) // limit to 200 characters
                    }
                    .onSubmit {
                        focusedField = nil
                    }
                    .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                        if keyboardHeight > 0 {
                            withAnimation(.easeOut) {
                                typing = true
                            }
                        } else {
                            withAnimation(.easeOut) {
                                typing = false
                            }
                        }
                    }
                    .alert(isPresented: $viewModel.categoriesUpdated) {
                        Alert(title: Text("Categories Saved"), dismissButton: .default(Text("OK")))
                    }
            }
            
            if !typing {
                // MARK: Still Available
                HStack {
                    Text("Still Available?").fontWeight(.bold).foregroundColor(Color("AccentColor"))

                    Spacer()

                    Rectangle()
                        .fill(viewModel.isAvailable ? .green : .clear)
                        .frame(width: 20, height: 20)
                        .border(.gray, width: 2)
                        .onTapGesture {
                            withAnimation {
                                viewModel.isAvailable.toggle()
                            }
                            
                            // send off the code that will update the availability of the item on the backend
                            viewModel.updateItemAvailability(itemId: itemId, itemIsAvailable: viewModel.isAvailable, user: user)
                        }
                        .alert(isPresented: $viewModel.updatedAvailability) {
                            Alert(title: Text("Success"), message: Text(viewModel.isAvailable ? "Your plant listing has been added back the market" : "Your plant listing has been removed from the market"), dismissButton: .default(Text("OK")))
                        }
                }.padding(.top)

                Menu("Actions") {
                    Button("Delete") {areYouSure.toggle()}
                    Button("Change Categories") { viewModel.isShowingCategoryPicker = true}
                    Button("Save Changes") {
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
                                let plantImage = plantImages[0]?.jpegData(compressionQuality: 0.5),
                                let plantImage2 = plantImages[1]?.jpegData(compressionQuality: 0.5),
                                let plantImage3 = plantImages[2]?.jpegData(compressionQuality: 0.5)
                            else {
                                return
                            }

                            viewModel.savePlant(accountid: user.accountId, plantImage: plantImage, plantImage2: plantImage2, plantImage3: plantImage3, itemId: itemId, user:user)
                        }
                }
                .font(.system(size: 20, weight: .heavy, design: .default))
                .alert(isPresented: $viewModel.missingCategories) {
                    Alert(title: Text("Missing Categories"), message: Text("Make sure to pick some categories for your plant"), dismissButton: .default(Text("OK")))
                }
            }
            
            Spacer()
                .alert(isPresented: $areYouSure) {
                    Alert(
                        title: Text("Are You Sure"),
                        message: Text("Once you delete your item we can't undo it."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.deleteItem(itemId: itemId, user:user)
                        },
                        secondaryButton: .cancel()
                    )
                }
        }
        .sheet(
            isPresented: $viewModel.isShowingCategoryPicker,
            onDismiss: {
                viewModel.saveNewCategories(itemId: itemId, user: user)
            }
        ) {
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
        .padding([.leading, .trailing])
    }
}

extension EditItem {
    func getImage(owner: String, itemName: String, imageNumber: Int) {
        if let encodedString = itemName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // Send the encodedString to the backend server

            // for each plant the images are stored as "image1", "image2", "image3"
            if let url: URL = URL(string: "https://rosegoldgardens.com/api/images/\(ownerName)/\(encodedString)/image\(imageNumber).jpg") {
                URLSession.shared.dataTask(with: url) { (data, response, err) in
                    guard err == nil else {
                        print("an error occurred")
                        return
                    }
                    
                    guard let imageData: Data = data else {
                        print("couldnt decode data")
                        return
                    }
                    if let uiImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.plantImages[imageNumber - 1] = uiImage
                        }
                    }
                }.resume()
            }
        }
    }
    
    func plantImagesAdded() -> Bool {
        for plant in plantImages {
            guard plant != nil else {
                return false
            }
        }
        return true
    }
}

struct EditItem_Previews: PreviewProvider {
    static var previews: some View {
        EditItem(itemName: "Shrubs", ownerName: "dee", itemId: 29).environmentObject(UserModel.shared)
    }
}
