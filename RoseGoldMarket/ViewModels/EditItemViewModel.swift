//
//  EditItemViewModle.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/7/22.
//

import Foundation
import SwiftUI
final class EditItemVM:ObservableObject {
    @Published var plantImage:UIImage? = nil // state var because this will change when the user picks their own image and we want to update the view with it
    @Published var plantImage2:UIImage? = nil
    @Published var plantImage3:UIImage? = nil
    @Published var isShowingPhotoPicker = false
    @Published var plantEnum: PlantOptions = .imageOne
    @Published var categoryHolder: [Category] = []
    @Published var plantName = ""
    @Published var plantDescription = ""
    @Published var isShowingCategoryPicker = false
    @Published var firstAppear = true
    @Published var isAvailable = true
    @Published var pickedUp = false
    @Published var itemIsDeleted = false
    @Published var showUpdateError = false
    @Published var tooManyChars = false
    @Published var networkError = false
    var viewStateErrors: EditItemViewStates = .allGood
    var categoryMapper = CategoryMapper()
    var service = ItemService()
    var categoryChosen: Bool {
        return 0 != self.categoryHolder.filter{ $0.isActive == true }.count
    }
    
    func getItemData(itemId:UInt, user:UserModel) {
        service.retrieveItemById(itemId: itemId, token: user.accessToken) {[weak self] itemDataResponse in
            switch itemDataResponse {
                case .success(let itemData):
                    DispatchQueue.main.async {
                        if itemData.newToken != nil {
                            user.accessToken = itemData.newToken!
                        }
                        self?.plantName = itemData.data.name
                        self?.plantDescription = itemData.data.description
                        
                        // go through the category list and set the toggle to true if it is present
                        for cat in itemData.data.categories {
                            let catId = self?.categoryMapper.categoriesByDescription[cat]
                            
                            // now find that category id in my array
                            let indexOfCategoryToActivate = self?.categoryHolder.firstIndex(where: {$0.category == catId})
                            
                            guard let indexOfCategoryToActivate = indexOfCategoryToActivate else {
                                return
                            }
                            
                            // now activate it since this category id was a pre-existing one in the db
                            self?.categoryHolder[indexOfCategoryToActivate].isActive = true
                            
                            self?.isAvailable = itemData.data.isavailable
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if error == .tokenExpired {
                            user.logout()
                        }
                        print("[EditItemVM] tried to get data for item \(itemId): \(error)")
                        self?.networkError = true
                    }
            }
        }
    }
    
    func getImages(itemName:String, ownerName:String) {
        let itemNameWithoutSpaces = itemName.replacingOccurrences(of: " ", with: "%20")
        // hit the server and grab the images for the item
        do {
            let imageUrl = URL(string: "http://localhost:4000/images/\(ownerName)/\(itemNameWithoutSpaces)/image1.jpg")!
            let image2Url = URL(string: "http://localhost:4000/images/\(ownerName)/\(itemNameWithoutSpaces)/image2.jpg")!
            let image3Url = URL(string: "http://localhost:4000/images/\(ownerName)/\(itemNameWithoutSpaces)/image3.jpg")!
            
            let image1 = try Data(contentsOf: imageUrl)
            let image2 = try Data(contentsOf: image2Url)
            let image3 = try Data(contentsOf: image3Url)
            
            
            self.plantImage = UIImage(data: image1)
            self.plantImage2 = UIImage(data: image2)
            self.plantImage3 = UIImage(data: image3)
        } catch let requestError {
            print("[EditItemVM] tried fetching item images: \(requestError.localizedDescription)")
        }
    }
    
    func deleteItem(itemId:UInt, user:UserModel) {
        service.deleteItem(itemId: itemId, itemName: self.plantName, token: user.accessToken) {[weak self] deletionResponse in
            switch deletionResponse {
                case .success(let resData):
                    DispatchQueue.main.async {
                        if resData.newToken != nil {
                            user.accessToken = resData.newToken!
                        }
                        self?.itemIsDeleted = true
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        if error == .tokenExpired {
                            user.logout()
                        }
                        print("[EditItemVM] tried deleting item: \(error)")
                        self?.networkError = true
                    }
            }
        }
    }
    
    func savePlant(accountid: UInt, plantImage: Data, plantImage2: Data, plantImage3: Data, itemId:UInt, user:UserModel) {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        let item = ItemForBackend(accountid: accountid, image1: plantImage, image2: plantImage2, image3: plantImage3, isavailable: self.isAvailable, pickedup: self.pickedUp, zipcode: 00000, dateposted: Date(), name: self.plantName, description: self.plantDescription, categoryIds: categoryIdList)
        
        service.updateItem(itemData: item, itemId: itemId, token: user.accessToken) {[weak self] apiRes in
            switch apiRes {
                case .success(let resData):
                    DispatchQueue.main.async {
                        if resData.newToken != nil {
                            user.accessToken = resData.newToken!
                        }
                        self?.viewStateErrors = .allGood
                        self?.showUpdateError = true
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        if err == .tokenExpired {
                            user.logout()
                        }
                        print("[EditItemVM] tried to save item \(itemId) after updates: \(err)")
                        self?.networkError = true
                    }
            }
        }
    }
}
