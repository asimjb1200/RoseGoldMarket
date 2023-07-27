//
//  AddItemsViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation
import SwiftUI

final class AddItemsViewModel: ObservableObject {
    @Published var isShowingPhotoPicker = false
    @Published var isShowingCategoryPicker = false
    @Published var plantName: String = ""
    @Published var plantDescription: String = ""
    @Published var itemPosted: Bool = false
    @Published var categories: [UInt] = []
    @Published var categoryHolder: [Category] = []
    @Published var showAlert = false
    @Published var sendingData = false
    @Published var errorOccurred = false
    @Published var plantImages: [PlantImage] = [PlantImage(id: UUID(), image: nil), PlantImage(id: UUID(), image: nil), PlantImage(id: UUID(), image: nil)]
    var viewStateErrors: AddItemViewStates = .imagesEmpty
    var categoryChosen: Bool {
        return 0 != self.categoryHolder.filter{ $0.isActive == true }.count
    }

    private var itemService = ItemService()
    
    init() {
        CategoryIds.allCases.forEach {
            // create a category object for each of the categories ids
            self.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
        }
    }
    
    func savePlant(accountid: UInt, plantImage: Data, plantImage2: Data, plantImage3: Data, user: UserModel) async {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        let item = ItemForBackend(accountid: accountid, image1: plantImage, image2: plantImage2, image3: plantImage3, isavailable: true, pickedup: false, zipcode: 00000, dateposted: Date(), name: self.plantName, description: self.plantDescription, categoryIds: categoryIdList)
        
        do {
            let response = try await itemService.postItemV2(itemData: item, token: user.accessToken)
            
            DispatchQueue.main.async {
                if response.newToken != nil {
                    user.accessToken = response.newToken!
                }
                self.itemPosted = true
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        } catch let err {
            DispatchQueue.main.async {
                self.errorOccurred = true

                print("[AddItemsVM] problem when trying to add a new plant for user \(user.accountId): \(err)")
            }
        }
    }
    
    func savePlantV2(accountid: UInt, plantImage: Data, plantImage2: Data, plantImage3: Data, user: UserModel) async -> Bool {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        let item = ItemForBackend(accountid: accountid, image1: plantImage, image2: plantImage2, image3: plantImage3, isavailable: true, pickedup: false, zipcode: 00000, dateposted: Date(), name: self.plantName, description: self.plantDescription, categoryIds: categoryIdList)
        
        DispatchQueue.main.async {
            self.sendingData = true
        }
        
        do {
            let response: ResponseFromServer<String> = try await itemService.postItemV2(itemData: item, token: user.accessToken)
            
            DispatchQueue.main.async {
                if response.newToken != nil {
                    user.accessToken = response.newToken!
                }
                self.plantName = ""
                self.plantDescription = ""
                self.itemPosted = true
                self.sendingData = false
            }
            return true
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                self.errorOccurred = true
                self.sendingData = false
                self.itemPosted = false
                user.logout()
            }
            return false
        } catch {
            DispatchQueue.main.async {
                self.errorOccurred = true
                self.sendingData = false
                self.itemPosted = false
            }
            return false
        }
    }
}
