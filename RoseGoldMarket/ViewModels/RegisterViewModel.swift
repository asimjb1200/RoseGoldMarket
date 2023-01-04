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
    @Published var addressLineTwo = ""
    @Published var phone = ""
    @Published var zipCode = ""
    @Published var state = ""
    @Published var city = ""
    @Published var avatar:UIImage?
    var useCamera = false
    @Published var dataPosted = false
    @Published var canLoginNow = false
    @Published var isShowingPhotoPicker = false
    @Published var spacesFoundInField = false
    @Published var fieldsEmpty = false
    @Published var addressIsFake = false
    @Published var specialCharFound = false
    @Published var passwordLengthIsInvalid = false
    @Published var pwNeedsNumbers = false
    @Published var invalidEmail = false
    @Published var pwNeedsCaps = false
    @Published var usernameLengthIsInvalid = false
    @Published var passwordNotComplex = false
    @Published var nameNotAvailable = false
    @Published var avatarNotUploaded = false
    @Published var showPW = false
    @Published var showConfPW = false
    @Published var addyNotFound = false
    @Published var emailTaken = false
    @Published var addressInfo: AddressInformation?
    @Published var loading = false
    @Published var statePicker: [String] = ["Select A State","AL","AK","AZ","AR","AS","CA","CO","CT","DE","DC","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","CM","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","TT","UT","VT","VI","WA","WV","WI","WY"]
    
    
    func registerUserV2(address:String, phone:String, city:String, state:String, zipCode:String, geolocation:String) -> () {
        guard
            let avatar = avatar,
            let avatarImgCompressed = avatar.jpegData(compressionQuality: 0.5)
        else {
            print("image wasn't set or i wasn't able to compress it")
            return
        }
        
        guard let zipCodeInt = UInt(zipCode) else { return }
        
        UserNetworking.shared.registerUser(firstName: self.firstName, lastName: self.lastName, username: self.username.lowercased(), email: self.email, phone: phone, pw: self.password, addy: address, zip: zipCodeInt, state: state, city: city, geolocation: geolocation, avi: avatarImgCompressed) { [weak self] registerResponse in
            switch registerResponse {
                case .success( _):
                    DispatchQueue.main.async {
                        print("data posted")
                        self?.loading = false
                        self?.dataPosted = true
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self?.loading = false
                        if err == .usernameTaken {
                            self?.nameNotAvailable = true
                        }
                        if err == .emailTaken {
                            self?.emailTaken = true
                        }
                        print(err)
                    }
            }
        }
    }
}
