//
//  User.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import Foundation



final class UserNetworking {
    let networker: Networker = Networker()
    static let shared: UserNetworking = UserNetworking()
    private let keyChainLabel = "bet-it-casino-access-token"
    
    func emailSupport(subject: String, message: String, token: String, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let reqWithoutBody: URLRequest = networker.constructRequest(uri: "http://localhost:4000/users/email-support", token: token, post: true)
        let session = URLSession.shared
        let body = ["subject": subject, "message": message]
        
        let request = networker.buildReqBody(req: reqWithoutBody, body: body)
        session.dataTask(with: request) {(_, response, error) in
            if error != nil {
                print("there was an error with the request")
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self.networker.checkOkStatus(res: response)
            if isOK {
                completion(.success(true))
            } else if response.statusCode ~= 403 {
                completion(.failure(.tokenExpired))
            } else {
                completion(.failure(.serverError))
            }
        }.resume()
    }
    
    func saveNewAddress(newAddress:String, newCity:String, newState:String, newZipCode:UInt, newGeoLocation:String, completion: @escaping (Result<Bool, SupportErrors>) -> ()) {
        let request = networker.constructRequest(uri: "http://localhost:4000/users/change-address", post: true)
        let body:[String:Any] = ["newAddress":newAddress, "newCity":newCity, "newState":newState, "newZip":newZipCode, "newGeolocation":newGeoLocation]
        let req = networker.buildReqBody(req: request, body: body)
        
        URLSession.shared.dataTask(with: req) {[weak self] (_, response, error) in
            if error != nil {
                completion(.success(false))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            let isOK = self?.networker.checkOkStatus(res: response)
            
            if let isOK = isOK {
                if isOK {
                    completion(.success(true))
                } else if response.statusCode ~= 403 {
                    completion(.failure(.tokenExpired))
                } else {
                    completion(.failure(.serverError))
                }
            }
        }.resume()
    }
    
    func fetchCurrentAddress(accountId: UInt, completion: @escaping (Result<AddressInfo, AccountDetailsErrors>) -> ()) {
        let request = networker.constructRequest(uri: "http://localhost:4000/users/address-details?accountId=\(accountId)", post: false)
        
        URLSession.shared.dataTask(with: request) {(data, response, err) in
            if err != nil {
                completion(.failure(.serverError))
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let addy = try JSONDecoder().decode(AddressInfo.self, from: data)
                completion(.success(addy))
            } catch let acctErr {
                print(acctErr)
                completion(.failure(.dataDecodingError))
            }
        }.resume()
    }
    
    func fetchUsersItems(accountId: UInt, completion: @escaping (Result<[ItemNameAndId], AccountDetailsErrors>) -> ()) {
        let req = networker.constructRequest(uri: "http://localhost:4000/users/user-items?accountId=\(accountId)", post: false)
        
        URLSession.shared.dataTask(with: req) {(data, response, error) in
            if error != nil {
                completion(.failure(.serverError))
            }
            
            guard let _ = response as? HTTPURLResponse else {
                completion(.failure(.responseConversionError))
                return
            }

            guard let data = data else {
                completion(.failure(.dataDecodingError))
                return
            }
            
            do {
                let itemData = try JSONDecoder().decode([ItemNameAndId].self, from: data)
                completion(.success(itemData))
            } catch let decodeError {
                print(decodeError.localizedDescription)
            }
        }.resume()
    }
    
//    func fetchItemImageData(itemOwner:String, itemName:String, completion: @escaping) {
//        
//    }
}


enum SupportErrors: String, Error {
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case requestError = "There was a problem making the request."
    case serverError = "There was an error with the request on the server."
    case responseConversionError = "Unable to decode http response."
}

enum AccountDetailsErrors: String, Error {
    case serverError = "There was an error processing the request."
    case tokenExpired = "The access token has expired. Time to issue a new one."
    case dataDecodingError = "There was a problem decoding the data."
    case responseConversionError = "Unable to decode http response."
}
