//
//  EditItem.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/4/22.
//

import SwiftUI

struct EditItem: View {
    @StateObject var viewModel = EditItemVM()
    @Environment(\.presentationMode) var presentation
    @State var areYouSure = false
    @EnvironmentObject var user:UserModel
    var categoryMapper = CategoryMapper()
    let itemName:String
    let ownerName:String
    let itemId:UInt
    
    var body: some View {
        VStack {
            Text("Tap to change your photos").foregroundColor(Color("AccentColor")).padding([.leading, .top])
            HStack {
                if viewModel.plantImage != nil {
                    Image(uiImage: viewModel.plantImage!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.plantEnum = .imageOne
                            viewModel.isShowingPhotoPicker = true
                        }
                } else {
                    ProgressView()
                }

                if viewModel.plantImage2 != nil {
                    Image(uiImage: viewModel.plantImage2!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.plantEnum = .imageTwo
                            viewModel.isShowingPhotoPicker = true
                        }
                } else {
                    ProgressView()
                }

                if viewModel.plantImage3 != nil {
                    Image(uiImage: viewModel.plantImage3!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.plantEnum = .imageThree
                            viewModel.isShowingPhotoPicker = true
                        }
                } else {
                    ProgressView()
                }
            }.onAppear{
                viewModel.getImages(itemName: self.itemName, ownerName: self.ownerName)
            }
            .navigationBarTitle("Edit Item")
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Plant Name:").foregroundColor(Color("AccentColor")).padding(.leading).onAppear(){ viewModel.getItemData(itemId: itemId, user: user) }
            TextField("", text: $viewModel.plantName)
                .textFieldStyle(OvalTextFieldStyle())
                .padding([.leading, .trailing])
            
            Text("Description").foregroundColor(Color("AccentColor")).padding([.leading, .top])
            TextEditor(text: $viewModel.plantDescription)
                .padding(.leading)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 0.778, green: 0.817, blue: 0.851))
                )
                .frame( height: 100)
                .padding([.leading, .trailing, .bottom])
            
            Toggle("Still available?", isOn: $viewModel.isAvailable)
                .padding(.leading)
                .foregroundColor(Color("AccentColor"))
                .alert(isPresented: $viewModel.itemIsDeleted) {
                    Alert(title: Text("Success"), message: Text("Your item has been deleted"), dismissButton: .default(Text("OK"), action: {self.presentation.wrappedValue.dismiss()}))
                }
            
            if !viewModel.isAvailable {
                Toggle("Has it been picked up?", isOn: $viewModel.pickedUp).padding(.leading)
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
                        .padding([.leading, .trailing])
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
            
//            Spacer()
            
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
                        let plantImage = viewModel.plantImage?.jpegData(compressionQuality: 0.5),
                        let plantImage2 = viewModel.plantImage2?.jpegData(compressionQuality: 0.5),
                        let plantImage3 = viewModel.plantImage3?.jpegData(compressionQuality: 0.5)
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
                                    action: { self.presentation.wrappedValue.dismiss() }
                                )
                            )
                    }
                }
            }
            .padding(.bottom)
            
            
        }.sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
            if viewModel.plantImage != nil, viewModel.plantImage2 != nil, viewModel.plantImage3 != nil {
                PhotoPicker(plantImage: $viewModel.plantImage, plantImage2: $viewModel.plantImage2, plantImage3: $viewModel.plantImage3, plantEnum: $viewModel.plantEnum)

            }
        })
    }
}

struct EditItem_Previews: PreviewProvider {
    static var previews: some View {
        EditItem(itemName: "Shrubs", ownerName: "dee", itemId: 25)
    }
}
