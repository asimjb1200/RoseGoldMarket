//
//  ItemForBackend.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import Foundation

struct ItemForBackend: Codable {
    let accountid: UInt
    let image1: Data
    let image2: Data
    let image3: Data
    let isavailable: Bool
    let pickedup: Bool
    let zipcode: UInt
    let dateposted: Date
    let name: String
    let description: String
    let filename1: String
    let filename2: String
    let filename3: String
    let categoryIds: [UInt]
    
    init(accountid: UInt, image1: Data, image2:Data, image3:Data, isavailable:Bool,
         pickedup:Bool, zipcode:UInt, dateposted: Date, name:String, description: String, categoryIds: [UInt]) {
        self.accountid = accountid
        self.image1 = image1
        self.image2 = image2
        self.image3 = image3
        self.isavailable = isavailable
        self.pickedup = pickedup
        self.zipcode = zipcode
        self.dateposted = dateposted
        self.name = name
        self.description = description
        self.categoryIds = categoryIds
        self.filename1 = "image1.jpg"
        self.filename2 = "image2.jpg"
        self.filename3 = "image3.jpg"
    }
    
    func getParams() -> [String: Any] {
        let params: [String: Any] = [
            "accountid": accountid,
            "isavailable": isavailable,
            "pickedup": pickedup,
            "zipcode": zipcode,
            "dateposted": dateposted,
            "name": name,
            "description": description,
            "categoryIds": categoryIds
        ]
        
        return params
    }
}
