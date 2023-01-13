//
//  EditItem.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/4/22.
//

import SwiftUI
import Combine // for access to the publisher

struct EditItem: View {
    @StateObject var viewModel = EditItemVM()
    @Environment(\.dismiss) private var dismiss
    @State var areYouSure = false
    @EnvironmentObject var user:UserModel
    @State var descOffset: CGFloat = 0
    @State var typing = false
    var categoryMapper = CategoryMapper()
    let itemName:String
    let ownerName:String
    let itemId:UInt
    private enum EditFields: Int, CaseIterable {
        case name, description
    }
    @FocusState private var focusedField:EditFields?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tap to change your photos")
                .foregroundColor(Color("AccentColor"))
                .padding([.leading, .top])
                .offset(y: descOffset * -1)
            
            // MARK: Plant Photos
            HStack {
                ForEach($viewModel.plantImages, id: \.id) { $data in
                    ZStack {
                        Circle() // outer rim
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(.lightGray))
                            .shadow(radius: 25)
                            .task {
                                getImage(owner: ownerName, itemName: itemName, plantID: data.id)
                            }
                        
                        if data.image != nil {
                            Image(uiImage: data.image!)
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
                }
            }
            .offset(y: descOffset * -1)
            .navigationBarTitle(Text(self.typing ? "" : "Edit Item"), displayMode: .inline)
            .frame(maxWidth: .infinity, alignment: .center)
            .alert(isPresented: $viewModel.networkError) {
                Alert(title:Text("A Problem Occurred"), message: Text("Something went wrong on our end. try again later"))
            }
            
            // MARK: Plant Name
            Group {
                Text("Name:").foregroundColor(Color("AccentColor")).padding(.leading)
                TextField("", text: $viewModel.plantName)
                    .padding()
                    .focused($focusedField, equals: .name)
                    .modifier(CustomTextBubble(isActive: focusedField == EditFields.name, accentColor: .blue))
                    .padding([.leading, .trailing])
                    .shadow(radius: 5)
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
                    .onAppear(){ viewModel.getItemData(itemId: itemId, user: user) }
            }.offset(y: descOffset * -1)
            
            // MARK: Description
            Group {
                Text("Description:")
                    .foregroundColor(Color("AccentColor"))
                    .padding([.leading, .top])
                    .alert(isPresented: $viewModel.tooManyChars) {
                        Alert(title: Text("Too Many Characters"), message: Text("Name field can have no more than 20 characters. The description field can have no more than 200."))
                    }
                
                TextEditor(text: $viewModel.plantDescription)
                    .padding(.leading)
                    .frame( height: 200)
                    .focused($focusedField, equals: .description)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20.0).stroke(focusedField == EditFields.description ? .blue : .gray, lineWidth: focusedField == EditFields.description ? 3 : 1).shadow(radius: 5)
                    )
                    .padding([.leading, .trailing, .bottom])
                    .onChange(of: viewModel.plantDescription) {
                        viewModel.plantDescription = String($0.prefix(200)) // limit to 200 characters
                    }
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .offset(y: self.descOffset * -1)
            
            Toggle("Still available?", isOn: $viewModel.isAvailable)
                .padding(.leading)
                .tint(Color("MainColor"))
                .alert(isPresented: $viewModel.itemIsDeleted) {
                    Alert(title: Text("Success"), message: Text("Your item has been deleted"), dismissButton: .default(Text("OK"), action: { dismiss() }))
                }
            
            if !viewModel.isAvailable {
                Toggle("Has it been picked up?", isOn: $viewModel.pickedUp).padding(.leading).tint(Color("MainColor"))
            }
            
            Button("Change Categories") {
                viewModel.isShowingCategoryPicker = true
            }
            .onAppear() {
                if viewModel.firstAppear {
                    viewModel.firstAppear = false
                    CategoryIds.allCases.forEach {
                        // create a category object for each of the categories ids
                        viewModel.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
                    }
                }
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
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
            
            HStack {
                Text("Delete Item")
                .onTapGesture {
                    areYouSure = true
                }
                .foregroundColor(.red)
                .padding()
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
                
                Button("Update Item") {
                    // figure out if the images have been changed etc
                    guard !viewModel.plantName.isEmpty else {
                        viewModel.viewStateErrors = .nameEmpty
                        viewModel.showUpdateError = true
                        return
                    }
                    guard !viewModel.plantDescription.isEmpty else {
                        viewModel.viewStateErrors = .descriptionEmpty
                        viewModel.showUpdateError = true
                        return
                    }
                    guard viewModel.categoryChosen == true else {
                        viewModel.viewStateErrors = .noCategory
                        viewModel.showUpdateError = true
                        return
                    }
                    
                    guard
                        viewModel.plantDescription.count <= 200,
                        viewModel.plantName.count <= 20
                    else {
                        viewModel.tooManyChars = true
                        return
                    }
                    
                    guard
                        let plantImage = viewModel.plantImages[0].image?.jpegData(compressionQuality: 0.5),
                        let plantImage2 = viewModel.plantImages[1].image?.jpegData(compressionQuality: 0.5),
                        let plantImage3 = viewModel.plantImages[2].image?.jpegData(compressionQuality: 0.5)
                    else {
                        return
                    }
                    
                    viewModel.savePlant(accountid: user.accountId, plantImage: plantImage, plantImage2: plantImage2, plantImage3: plantImage3, itemId: itemId, user:user)
                }
                .foregroundColor(Color("MainColor"))
                .padding()
                .alert(isPresented: $viewModel.showUpdateError) {
                    switch viewModel.viewStateErrors {
                        case .imagesEmpty:
                            return Alert(title: Text("Image Selections"), message: Text("Make sure you upload 3 pictures of your plant so that people can see what they are getting."), dismissButton: .default(Text("OK!")))
                        case .nameEmpty:
                            return Alert(title: Text("Plant Name"), message: Text("Enter the name of your plant so that people will know what they are getting."), dismissButton: .default(Text("OK!")))
                        case .descriptionEmpty:
                            return Alert(title: Text("Plant Description"), message: Text("Add a description of your plant to give other users a little bit of information about it."), dismissButton: .default(Text("OK!")))
                        case .noCategory:
                            return Alert(title: Text("Plant Categories"), message: Text("Select some categories that your plant falls under so that users will be able to find it easier."), dismissButton: .default(Text("OK!")))
                        case .allGood:
                            return Alert(
                                title: Text("Success"),
                                message: Text("Your item has been updated."),
                                dismissButton: .default(
                                    Text("OK"),
                                    action: { dismiss() }
                                )
                            )
                    }
                }
            }
            .padding(.bottom)
        }.sheet(isPresented: $viewModel.isShowingPhotoPicker){
            ImageSelector(image: Binding.constant(nil), canSelectMultipleImages: true, images: $viewModel.plantImages)
        }
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
}

struct EditItem_Previews: PreviewProvider {
    static var previews: some View {
        EditItem(itemName: "Shrubs", ownerName: "dee", itemId: 25)
    }
}
