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
    
    func updateItemAvailability(itemId:UInt, itemIsAvailable: Bool, user:UserModel) async {
        do {
            let res = try await service.updateItemAvailabilityV2(itemId: itemId, itemIsAvailable: itemIsAvailable, token: user.accessToken)
            
            DispatchQueue.main.async {
                if res.newToken != nil {
                    user.accessToken = res.newToken!
                }
                
                self.updatedAvailability = res.data
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        } catch {
            
        }
    }
    
    func getItemData(itemId:UInt, user:UserModel) async {
        DispatchQueue.main.async {
            self.itemDataLoaded = true
        }
        
        do {
            let itemData = try await service.retrieveItemByIdV2(itemId: itemId, token: user.accessToken)
            DispatchQueue.main.async {
                if itemData.newToken != nil {
                    user.accessToken = itemData.newToken!
                }
                self.plantName = itemData.data.name
                self.plantDescription = itemData.data.description
                self.isAvailable = itemData.data.isavailable
                
                
                
                // populate the category holder
                for (categoryId, catDescription) in self.categoryMapper.categories {
                    // search for the category in the item that was passed back. If it is found, we know that we have to activate the current category
                    let categoryMatchFound = itemData.data.categories.first(where: { $0.replacingOccurrences(of: "\n", with: "") == catDescription }) != nil
                    self.categoryHolder.append(Category(category: categoryId, isActive: categoryMatchFound))
                }
                
                self.itemDataLoaded = true
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        }catch let err {
            DispatchQueue.main.async {
                print("[EditItemVM] tried to get data for item \(itemId): \(err)")
                self.networkError = true
                self.itemDataLoaded = true
            }
        }
    }
    
    func deleteItem(itemId:UInt, user:UserModel) async {
        do {
            let resData = try await service.deleteItemV2(itemId: itemId, itemName: plantName, token: user.accessToken)
            DispatchQueue.main.async {
                if resData.newToken != nil {
                    user.accessToken = resData.newToken!
                }
                self.itemIsDeleted = true
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        } catch let err {
            DispatchQueue.main.async {
                print("[EditItemVM] tried deleting item: \(err)\n\(err)")
                self.networkError = true
            }
        }
    }
    
    func saveNewCategories(itemId: UInt, user:UserModel) async {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        
        do {
            let resData = try await service.updateCategoriesV2(newCategories: categoryIdList, itemId: itemId, token: user.accessToken)
            
            DispatchQueue.main.async {
                if resData.newToken != nil {
                    user.accessToken = resData.newToken!
                }
                self.categoriesUpdated = true
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        } catch let err {
            print(err)
        }
    }
    
    func savePlant(accountid: UInt, plantImage: Data, plantImage2: Data, plantImage3: Data, itemId:UInt, user:UserModel) async {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        let item = ItemForBackend(accountid: accountid, image1: plantImage, image2: plantImage2, image3: plantImage3, isavailable: self.isAvailable, pickedup: self.pickedUp, zipcode: 00000, dateposted: Date(), name: self.plantName, description: self.plantDescription, categoryIds: categoryIdList)
        
        do {
            let resData = try await service.updateItemV2(itemData: item, itemId: itemId, token: user.accessToken)
            DispatchQueue.main.async {
                if resData.newToken != nil {
                    user.accessToken = resData.newToken!
                }
                self.plantUpdated = true
//                        self?.viewStateErrors = .allGood
//                        self?.showUpdateError = true
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        } catch let err {
            DispatchQueue.main.async {
                print("[EditItemVM] tried to save item \(itemId) after updates: \(err)")
                self.networkError = true
            }
        }
    }
}
