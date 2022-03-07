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
    var categoryMapper = CategoryMapper()
    
    func getItemData(itemId:UInt) {
        ItemService().retrieveItemById(itemId: itemId) {[weak self] itemDataResponse in
            switch itemDataResponse {
            case .success(let itemData):
                DispatchQueue.main.async {
                    self?.plantName = itemData.name
                    self?.plantDescription = itemData.description
                    
                    // go through the category list and set the toggle to true if it is present
                    for cat in itemData.categories {
                        let catId = self?.categoryMapper.categoriesByDescription[cat]
                        
                        // now find that category id in my array
                        let indexOfCategoryToActivate = self?.categoryHolder.firstIndex(where: {$0.category == catId})
                        
                        guard let indexOfCategoryToActivate = indexOfCategoryToActivate else {
                            return
                        }
                        
                        // now activate it since this category id was a pre-existing one in the db
                        self?.categoryHolder[indexOfCategoryToActivate].isActive = true
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
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
            print(requestError.localizedDescription)
        }
    }
}
