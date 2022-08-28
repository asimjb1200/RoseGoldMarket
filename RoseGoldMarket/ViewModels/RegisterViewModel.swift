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
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var address = ""
    @Published var zipCode = ""
    @Published var state = ""
    @Published var city = ""
    @Published var avatar:UIImage? = UIImage(systemName: "plus.circle.fill")!.withTintColor(.white, renderingMode: .alwaysTemplate)
    @Published var dataPosted = false
    @Published var imageEnum: PlantOptions = .imageOne
    @Published var isShowingPhotoPicker = false
    @Published var spacesFoundInField = false
    @Published var fieldsEmpty = false
    @Published var addressIsFake = false
    @Published var specialCharFound = false
    @Published var passwordLengthIsInvalid = false
    @Published var usernameLengthIsInvalid = false
    @Published var passwordNotComplex = false
    @Published var nameNotAvailable = false
    @Published var avatarNotUploaded = false
    @Published var showPW = false
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
        
        guard let zipCodeInt = UInt(self.zipCode) else { return }

        UserNetworking.shared.registerUser(firstName: self.firstName, lastName: self.lastName, username: self.username.lowercased(), email: self.email, pw: self.password, addy: self.address, zip: zipCodeInt, state: self.state, city: self.city, geolocation: geolocation, avi: avatarImgCompressed) {[weak self] registerResponse in
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
        for field in [self.firstName, self.lastName, self.username, self.email, self.password, self.address, self.zipCode, self.state, self.city] {
            if field.isEmpty {
                fieldIsEmpty = true
                break
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
    
    func pwContainsUppercase() -> Bool {
        var uppercaseFound = false
        for chr in self.password {
            if chr.isUppercase {
                uppercaseFound = true
                break
            }
        }
        return uppercaseFound
    }
    
    func pwContainsNumber() -> Bool {
        var numberFound = false
        for chr in self.password {
            if chr.isNumber {
                numberFound = true
                break
            }
        }
        return numberFound
    }
    
    func containsEnoughChars(text:String) -> Bool {
        var containsEnoughChars = false
        var charCount = 0
        
        guard text.count > 7 else {
            return containsEnoughChars
        }
        
        for char in text {
            if char.isLetter {
                charCount += 1
                if charCount >= 5 {
                    containsEnoughChars = true
                    break
                }
            }
        }
        return containsEnoughChars
    }
}
