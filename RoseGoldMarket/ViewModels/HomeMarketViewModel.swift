//
//  HomeMarketViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/28/22.
//

import Foundation

final class HomeMarketViewModel: ObservableObject {
    @Published var items: [Item] = [Item]()
    @Published var searchTerm: String = ""
    @Published var showFilterSheet = false
    @Published var categoryHolder: [Category] = []
    @Published var isLoadingPage = false
    @Published var searchRadius: UInt = 20
//    @Published var canLoadMorePages = true
    @Published var allDataLoaded = false
    var searchButtonPressed = false
    
    private var currentOffset: UInt = 0
    let service = ItemService()
    let mileOptions: [UInt] = [5, 10, 15, 20]
    
    init() {
        CategoryIds.allCases.forEach {
            // create a category object for each of the categories ids
            self.categoryHolder.append(Category(category: $0.rawValue, isActive: false))
        }
        self.getFilteredItems()
    }
    
    func getFilteredItems() -> () {
        self.isLoadingPage = true
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        
        // if the user has prompted a search, reset all search variables
        if searchButtonPressed {
            self.items = []
            self.currentOffset = 0
            self.allDataLoaded = false
            self.searchButtonPressed = false
        }
        
        service.retrieveItems(categoryIdFilters: categoryIdList, limit: 10, offset: currentOffset, longAndLat: "(-94.594299,39.044432)", miles: searchRadius, searchTerm: searchTerm, completion: {[weak self] itemResponse in
            switch itemResponse {
                case .success(let itemData):
                    DispatchQueue.main.async {
                        if !itemData.isEmpty {
                            self?.currentOffset += 10
                            self?.items.append(contentsOf: itemData) // add new items to the end of array for infinite scroll
                            self?.isLoadingPage = false
                        } else {
                            self?.currentOffset = 0
                            self?.allDataLoaded = true
                            self?.isLoadingPage = false
                        }
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }
}
