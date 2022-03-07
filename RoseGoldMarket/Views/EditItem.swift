//
//  EditItem.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/4/22.
//

import SwiftUI

struct EditItem: View {
    @StateObject var viewModel = EditItemVM()
    var categoryMapper = CategoryMapper()
    let itemName:String
    let ownerName:String
    let itemId:UInt
    
    var body: some View {
        VStack {
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
                            viewModel.plantEnum = .imageOne
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
                            viewModel.plantEnum = .imageOne
                            viewModel.isShowingPhotoPicker = true
                        }
                } else {
                    ProgressView()
                }
            }.onAppear{
                print("on appear for editing images running")
                viewModel.getImages(itemName: self.itemName, ownerName: self.ownerName)
            }
            .navigationBarTitle("Edit Item")
            .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Plant Name:").foregroundColor(Color("AccentColor")).padding(.leading).onAppear(){ viewModel.getItemData(itemId: itemId) }
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
            
            HStack {
                Toggle("Still available?", isOn: $viewModel.isAvailable)
                
                if !viewModel.isAvailable {
                    Toggle("Has it been picked up?", isOn: $viewModel.pickedUp)
                }
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
            
            Spacer()
            
            Button("Delete Item") {
                
            }.foregroundColor(.red).padding()
            
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
