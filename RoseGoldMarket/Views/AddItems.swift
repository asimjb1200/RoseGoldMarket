//
//  AddItems.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

struct AddItems: View {
    @State var plantImage = UIImage(named: "circlePlaceholder")! // state var because this will change when the user picks their own image and we want to update the view with it
    @State var plantImage2 = UIImage(named: "circlePlaceholder")!
    @State var plantImage3 = UIImage(named: "circlePlaceholder")!
    @StateObject var viewModel = AddItemsViewModel()
    @Binding var tab: Int
    var categoryMapper = CategoryMapper()
    
    init(tab: Binding<Int>) {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UITextView.appearance().backgroundColor = .clear
        self._tab = tab // initialize a binding
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Add 3 photos of your plant").foregroundColor(Color("AccentColor")).padding([.leading, .top])
                HStack {
                        Image(uiImage: plantImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .onTapGesture {
                                viewModel.plantEnum = .imageOne
                                viewModel.isShowingPhotoPicker = true
                            }

                        Image(uiImage: plantImage2)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .onTapGesture {
                                viewModel.plantEnum = .imageTwo
                                viewModel.isShowingPhotoPicker = true
                            }
                        
                        Image(uiImage: plantImage3)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .onTapGesture {
                                viewModel.plantEnum = .imageThree
                                viewModel.isShowingPhotoPicker = true
                            }
                }.frame(maxWidth: .infinity, alignment: .center)
                
                Text("Plant Name:").foregroundColor(Color("AccentColor")).padding(.leading)
                TextField("...", text: $viewModel.plantName)
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

                Button("Choose Categories") {
                    viewModel.isShowingCategoryPicker = true
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
                .alert(isPresented: $viewModel.itemPosted) {
                    return Alert(title: Text("Success"), message: Text("Your plant is now live on the market!"), dismissButton: .default(Text("OK!"), action: {
                        self.tab = 0
                    }))
                }
                
                Button("Submit") {
                    guard self.imageWasntChanged() == false else {
                        viewModel.viewStateErrors = .imagesEmpty
                        viewModel.showAlert = true
                        print("image wasn't changed")
                        return
                    }
                    guard !viewModel.plantName.isEmpty else {
                        viewModel.viewStateErrors = .nameEmpty
                        viewModel.showAlert = true
                        return
                    }
                    guard !viewModel.plantDescription.isEmpty else {
                        viewModel.viewStateErrors = .descriptionEmpty
                        viewModel.showAlert = true
                        return
                    }
                    guard viewModel.categoryChosen == true else {
                        viewModel.viewStateErrors = .noCategory
                        viewModel.showAlert = true
                        return
                    }

                    viewModel.savePlant(accountid: 5, plantImage: plantImage.jpegData(compressionQuality: 0.5)!, plantImage2: plantImage2.jpegData(compressionQuality: 0.5)!, plantImage3: plantImage3.jpegData(compressionQuality: 0.5)!)
                }
                .padding()
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                    .fill(Color("AccentColor"))
                )
                .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
                .alert(isPresented: $viewModel.showAlert) {
                    switch viewModel.viewStateErrors {
                        case .imagesEmpty:
                            return Alert(title: Text("Image Selections"), message: Text("Make sure you upload 3 pictures of your plant so that people can see what they are getting."), dismissButton: .default(Text("OK!")))
                        case .nameEmpty:
                            return Alert(title: Text("Plant Name"), message: Text("Enter the name of your plant so that people will know what they are getting."), dismissButton: .default(Text("OK!")))
                        case .descriptionEmpty:
                            return Alert(title: Text("Plant Description"), message: Text("Add a description of your plant to give other users a little bit of information about it."), dismissButton: .default(Text("OK!")))
                        case .noCategory:
                            return Alert(title: Text("Plant Categories"), message: Text("Select some categories that your plant falls under so that users will be able to find it easier."), dismissButton: .default(Text("OK!")))
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle(Text("Add Plant"))
            .sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
                PhotoPicker(plantImage: $plantImage, plantImage2: $plantImage2, plantImage3: $plantImage3, plantEnum: $viewModel.plantEnum)
            })
        }
    }
    
    func imageWasntChanged() -> Bool {
        let x: [Bool] = [
            self.plantImage.isEqual(UIImage(named: "circlePlaceholder")!),
            self.plantImage2.isEqual(UIImage(named: "circlePlaceholder")!),
            self.plantImage3.isEqual(UIImage(named: "circlePlaceholder")!)
        ]
        
        return 0 != x.filter{ $0 == true }.count
    }
}



struct AddItems_Previews: PreviewProvider {
    @State var tab = 0
    static var previews: some View {
        Text("hey")
        //AddItems(tab: $tab)
//            .preferredColorScheme(.dark)
    }
}

struct OvalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color(red: 0.778, green: 0.817, blue: 0.851))
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
