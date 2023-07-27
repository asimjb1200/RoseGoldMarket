//
//  HomeMarketViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/28/22.
//

import Foundation
import CoreLocation

final class HomeMarketViewModel: ObservableObject {
    @Published var items: [Item] = [Item]()
    @Published var searchTerm: String = ""
    @Published var showFilterSheet = false
    @Published var categoryHolder: [Category] = []
    @Published var isLoadingPage = false
    @Published var searchRadius: UInt = 20
    @Published var allDataLoaded = false
    @Published var errorOccurred = false
    var searchButtonPressed = false
    
    private var currentOffset: UInt = 0
    
    let service = ItemService()
    let userService: UserNetworking = .shared
    
    let mileOptions: [UInt] = [5, 10, 15, 20]
    
    init() {
        CategoryIds.allCases.forEach {
            // create a category object for each of the categories ids
            self.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
        }
    }
    
    func getFilteredItemsV2(user:UserModel, geoLocation:String) async {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        
        // if the user has prompted a search, reset all search variables
        await MainActor.run { // doing this to make sure that this code always runs before the search kicks off
            if self.searchButtonPressed {
                //print("resetting search stuff")
                self.items = []
                self.currentOffset = 0
                self.allDataLoaded = false
                self.searchButtonPressed = false
            }
        }
        
        do {
            //print("starting network code")
            let itemData = try await service.retrieveItemsV2(categoryIdFilters: categoryIdList, limit: 10, offset: currentOffset, longAndLat: geoLocation, miles: searchRadius, searchTerm: searchTerm, token: user.accessToken)
            
            DispatchQueue.main.async {
                if itemData.newToken != nil {
                    user.accessToken = itemData.newToken!
                }
                
                if !itemData.data.isEmpty {
                    self.currentOffset += 10
                    
                    // make sure the items aren't already in the array
                    for newItem in itemData.data {
                        if self.items.contains(where: { $0.id == newItem.id }) == false {
                            self.items.append(newItem)
                        }
                    }
                    
                    //self?.items.append(contentsOf: itemData.data) // add new items to the end of array for infinite scroll
                    self.isLoadingPage = false
                } else {
                    self.currentOffset = 0
                    self.allDataLoaded = true
                    self.isLoadingPage = false
                }
            }
        } catch ItemErrors.tokenExpired {
            DispatchQueue.main.async {
                user.logout()
            }
        }
        catch let err {
            print(err)
            DispatchQueue.main.async {
                self.items = []
            }
        }
    }
}
