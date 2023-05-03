//
//  EditItemViewModle.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/7/22.
//

import Foundation
import SwiftUI
final class EditItemVM:ObservableObject {
    @Published var categoryHolder: [Category] = []
    @Published var plantName = ""
    @Published var plantDescription = ""
    @Published var isShowingCategoryPicker = false
    @Published var firstAppear = true
    @Published var isAvailable = true
    @Published var pickedUp = false
    @Published var updatedAvailability = false
    @Published var itemIsDeleted = false
    @Published var addPhotos = false
    @Published var missingCategories = false
    @Published var categoriesUpdated = false
    @Published var showUpdateError = false
    @Published var tooManyChars = false
    @Published var networkError = false
    @Published var plantUpdated = false
    @Published var itemDataLoaded = false
    @Published var plantImages: [PlantImage] = [PlantImage(id: UUID(), image: nil), PlantImage(id: UUID(), image: nil), PlantImage(id: UUID(), image: nil)]
    
    var viewStateErrors: EditItemViewStates = .allGood
    var categoryMapper = CategoryMapper()
    var service = ItemService()
    
    var categoryChosen: Bool {
        return 0 != self.categoryHolder.filter{ $0.isActive == true }.count
    }
    
    func updateItemAvailability(itemId:UInt, itemIsAvailable: Bool, user:UserModel) {
        service.updateItemAvailability(itemId: itemId, itemIsAvailable: itemIsAvailable, token: user.accessToken) {[weak self] itemAvailabilityRes in
            switch itemAvailabilityRes {
                case .success(let res):
                    DispatchQueue.main.async {
                        if res.newToken != nil {
                            user.accessToken = res.newToken!
                        }
                        
                        self?.updatedAvailability = res.data
                    }
                case .failure(let err):
                    print(err)
            }
        }
    }
    
    func getItemData(itemId:UInt, user:UserModel) {
        self.itemDataLoaded = true
        service.retrieveItemById(itemId: itemId, token: user.accessToken) {[weak self] itemDataResponse in
            switch itemDataResponse {
                case .success(let itemData):
                    DispatchQueue.main.async {
                        if itemData.newToken != nil {
                            user.accessToken = itemData.newToken!
                        }
                        self?.plantName = itemData.data.name
                        self?.plantDescription = itemData.data.description
                        self?.isAvailable = itemData.data.isavailable
                        
                        // go through the category list and set the toggle to true if it is present
                        for cat in itemData.data.categories {
                            // some characters may have a new line character in there so remove it
                            let catId = self?.categoryMapper.categoriesByDescription[cat.replacingOccurrences(of: "\n", with: "")]
                            
                            // now find that category id in my array
                            let indexOfCategoryToActivate = self?.categoryHolder.firstIndex(where: {$0.category == catId})
                            
                            guard let indexOfCategoryToActivate = indexOfCategoryToActivate else {
                                return
                            }
                            
                            // now activate it since this category id was a pre-existing one in the db
                            self?.categoryHolder[indexOfCategoryToActivate].isActive = true
                        }
                        
                        self?.itemDataLoaded = true
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if error == .tokenExpired {
                            user.logout()
                        }
                        print("[EditItemVM] tried to get data for item \(itemId): \(error)")
                        self?.networkError = true
                        self?.itemDataLoaded = true
                    }
            }
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
    
    func saveNewCategories(itemId: UInt, user:UserModel) {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        
        service.updateCategories(newCategories: categoryIdList, itemId: itemId, token: user.accessToken) { [weak self] apiRes in
            switch apiRes {
                case .success(let resData):
                    DispatchQueue.main.async {
                        if resData.newToken != nil {
                            user.accessToken = resData.newToken!
                        }
                        if resData.data {
                            self?.categoriesUpdated = true
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err.localizedDescription)
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
                        self?.plantUpdated = true
//                        self?.viewStateErrors = .allGood
//                        self?.showUpdateError = true
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
