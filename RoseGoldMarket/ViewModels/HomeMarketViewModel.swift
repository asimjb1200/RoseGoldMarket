//
//  HomeMarketViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/28/22.
//

import Foundation

final class HomeMarketViewModel: ObservableObject {
    let service = ItemService()
    @Published var items: [Item] = []
    @Published var searchTerm: String = ""
    
    func getFilteredItems() -> () {
        service.retrieveItems(categoryIdFilters: [1,2,3], limit: 10, offset: 0, longAndLat: "(-94.594299,39.044432)", miles: 20, completion: {[weak self] itemResponse in
            switch itemResponse {
                case .success(let itemData):
                    DispatchQueue.main.async {
                        self?.items = itemData
                    }
                case .failure(let err):
                    print(err)
            }
        })
    }
    
    func sendSearchQueryToServer() {
        
    }
}
