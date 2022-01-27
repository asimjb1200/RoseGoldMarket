//
//  AddItemsViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation

final class AddItemsViewModel: ObservableObject {
    @Published var isShowingPhotoPicker = false
    @Published var isShowingCategoryPicker = false
    @Published var plantName: String = ""
    @Published var plantDescription: String = ""
    @Published var itemPosted: Bool = false
    @Published var plantEnum: PlantOptions = .imageOne
    @Published var categories: [UInt] = []
    @Published var categoryHolder: [Category] = []
    @Published var showAlert = false
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
    
    func savePlant(accountid: UInt, plantImage: Data, plantImage2: Data, plantImage3: Data) {
        let categoryIdList: [UInt] = self.categoryHolder.filter{ $0.isActive == true}.map{ $0.category }
        let item = ItemForBackend(accountid: 17, image1: plantImage, image2: plantImage2, image3: plantImage3, isavailable: true, pickedup: false, zipcode: 64111, dateposted: Date(), name: self.plantName, description: self.plantDescription, categoryIds: categoryIdList)
        
        itemService.postItem(itemData: item, completion: {[weak self] apiRes in
            switch apiRes {
                case .success( _):
                    DispatchQueue.main.async {
                        self?.itemPosted = true
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                    }
            }
        })
    }
    
}
