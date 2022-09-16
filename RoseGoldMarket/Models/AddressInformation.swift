//
//  AddressInformation.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/11/22.
//

import Foundation

struct AddressInformation: Codable {
    let geolocation:String
    let address:String
    let city:String
    let state:String
    let zipCode:String
}
