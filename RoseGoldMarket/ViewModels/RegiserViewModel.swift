//
//  RegiserViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import Foundation
import SwiftUI
import CoreLocation

final class RegisterUserViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var address = ""
    @Published var zipCode = ""
    @Published var state = ""
    @Published var city = ""
    @Published var avatar:UIImage? = UIImage(named: "default")!
    @Published var dataPosted = false
    @Published var imageEnum: PlantOptions = .imageOne
    @Published var isShowingPhotoPicker = false
    @Published var spacesFoundInField = false
    @Published var fieldsEmpty = false
    @Published var addressIsFake = false
    @Published var specialCharFound = false
    @Published var passwordLengthIsInvalid = false
    @Published var usernameLengthIsInvalid = false
    @Published var nameNotAvailable = false
    @Published var statePicker: [String] = ["Select A State","AL","AK","AZ","AR","AS","CA","CO","CT","DE","DC","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","CM","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","TT","UT","VT","VI","WA","WV","WI","WY"]
    
    func getAndSaveUserLocation() {
        let geocoder = CLGeocoder()
        let checkAddressForGeoLo = "\(self.address), \(self.city), \(self.state) \(self.zipCode)"
        geocoder.geocodeAddressString(checkAddressForGeoLo) { placemarks, error in
            guard error == nil else {
                self.addressIsFake = true
                return
            }
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            if let lon = lon, let lat = lat { // unwrap the optionals
                // (long, lat) for database now send new addy and long/lat to the database
                let geoLocation = "(\(lon),\(lat))"
                
                // register the new user
                self.registerUser(geolocation: geoLocation)
            }
        }
    }
    
    func registerUser(geolocation:String) -> () {
        guard
            let avatar = avatar,
            let avatarImgCompressed = avatar.jpegData(compressionQuality: 0.5)
        else {
            return
        }

        UserNetworking.shared.registerUser(username: self.username, email: self.email, pw: self.password, addy: self.address, zip: UInt(self.zipCode)!, state: self.state, city: self.city, geolocation: geolocation, avi: avatarImgCompressed) {[weak self] registerResponse in
            switch registerResponse {
                case .success(let res):
                    DispatchQueue.main.async {
                        self?.dataPosted = res
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        if err == .usernameTaken {
                            self?.nameNotAvailable = true
                        }
                        print(err)
                    }
            }
        }
    }
    
    func textFieldsEmpty() -> Bool {
        var fieldIsEmpty = false
        for field in [self.username, self.email, self.password, self.address, self.zipCode, self.state, self.city] {
            if field.isEmpty {
                if fieldIsEmpty == false {
                    fieldIsEmpty = true
                }
            }
        }
        return fieldIsEmpty
    }
    
    func spacesFound() -> Bool {
        var spacesFound = false
        for field in [self.username, self.email, self.password, self.zipCode, self.state] {
            if field.contains(" ") {
                if spacesFound == false {
                    spacesFound = true
                }
            }
        }
        return spacesFound
    }
}
